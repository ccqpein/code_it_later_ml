type crumb =
  | Nothing
  | Content of string
  | Content_with_keyword of string * string

let rec pick_comment_out (sym : string list) ~(line : string) : crumb =
  (* print_endline line ; *)
  match sym with
  | x :: xs ->
      let reg = Str.regexp (".*" ^ x ^ "+:= *") in
      if Str.string_match reg line 0 then
        Content (List.hd (Str.split reg line))
      else pick_comment_out xs ~line
  | [] -> Nothing

let keyword_filter keyword ~content:(x : crumb) : crumb =
  match x with
  | Content c ->
      let keyword_reg = Str.regexp (keyword ^ ": *") in
      if Str.string_match keyword_reg c 0 then
        Content_with_keyword (keyword ^ ":", List.hd (Str.split keyword_reg c))
      else Nothing
  | _ -> x

type linenum_crumb = {linenum: int; cmb: crumb}

let pickout_from_file filepath ?keyword commentmark : linenum_crumb list =
  let ic = open_in filepath in
  let result = ref [] in
  let _linenum = ref 0 in
  (* let keyword = match keyword with None -> "" | Some kk -> kk in *)
  try
    while true do
      let cont =
        match keyword with
        | None -> pick_comment_out ~line:(input_line ic) commentmark
        | Some kk ->
            keyword_filter kk
              ~content:(pick_comment_out ~line:(input_line ic) commentmark)
      in
      _linenum := !_linenum + 1 ;
      match cont with
      | Content _ | Content_with_keyword _ ->
          result := {linenum= !_linenum; cmb= cont} :: !result
      | _ -> ()
    done ;
    print_endline filepath ;
    !result
  with End_of_file -> close_in ic ; List.rev !result

let read_comment_mark_map filepath = Yojson.Basic.from_file filepath

(* give default comments mark table *)
let default_json = Yojson.Basic.from_string Args.default_json_string

let get_comment_mark json ~lang =
  let open Yojson.Basic.Util in
  let json_obj = json |> member lang in
  match json_obj with
  | `List _ -> json_obj |> to_list |> filter_string
  | `String s -> [s]
  | _ -> []

let rec get_all_file dir =
  (* clean "/" at endding of dir even sys module can parse it anyway *)
  let dir =
    match Str.split (Str.regexp "/*$") dir with x :: _ -> x | _ -> dir
  in
  let root_files = Array.to_list (Sys.readdir dir) in
  let re = ref [] in
  let rec walk_dir root_fs =
    match root_fs with
    | x :: xs when Sys.is_directory (dir ^ "/" ^ x) ->
        re := List.append !re (get_all_file (dir ^ "/" ^ x)) ;
        walk_dir xs
    | x :: xs when Filename.extension x != "" ->
        re := List.append !re [dir ^ "/" ^ x] ;
        walk_dir xs
    | _ :: xs -> walk_dir xs
    | _ -> ()
  in
  walk_dir root_files ; !re

let run_code ?keyword ?comm_dict_path dir : (string * linenum_crumb list) list
    =
  let open List in
  let all_files = get_all_file dir in
  let comment_map =
    match comm_dict_path with
    | Some p -> read_comment_mark_map p
    | None -> default_json
  in
  let all_crumb =
    filter
      (fun ele -> snd ele != [])
      (map
         (fun file ->
           let filetype = Filename.extension file in
           let comment_marks = get_comment_mark comment_map ~lang:filetype in
           (file, pickout_from_file file comment_marks ?keyword) )
         all_files)
  in
  all_crumb

let format_crumb ((filepath : string), (ln_crumb : linenum_crumb list)) =
  Printf.printf "|-- %s\n" filepath ;
  let _ =
    List.map
      (fun x ->
        match x.cmb with
        | Content s -> Printf.printf "  |-- Line %d: %s\n" x.linenum s
        | Content_with_keyword (s, s1) ->
            Printf.printf "  |-- Line %d: %s %s\n" x.linenum s s1
        | _ -> () )
      ln_crumb
  in
  print_endline ""

(* main function *)
let () =
  (* let _ = Array.iter print_endline Sys.argv in *)
  let args = match Array.to_list Sys.argv with _ :: xs -> xs | _ -> [] in
  let re = Args.handle_argvs args in
  let result =
    run_code re.dir ?comm_dict_path:re.mark_table_path ?keyword:re.keyword
  in
  let _ = List.map format_crumb result in
  ()
