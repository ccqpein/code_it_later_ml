type crumb =
  | Nothing
  | Content of string
  | Content_with_keyword of string * string

let rec pick_comment_out (sym : string list) ~(line : string) : crumb =
  (* print_endline line ; *)
  match sym with
  | x :: xs ->
      let reg = Str.regexp (".*" ^ x ^ "*:= *") in
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
      else x
  | _ -> x

type linenum_crumb = {linenum: int; cmb: crumb}

let pickout_from_file filepath commentmark : linenum_crumb list =
  let ic = open_in filepath in
  let result = ref [] in
  let _linenum = ref 0 in
  try
    while true do
      let cont = pick_comment_out ~line:(input_line ic) commentmark in
      _linenum := !_linenum + 1 ;
      match cont with
      | Content _ -> result := {linenum= !_linenum; cmb= cont} :: !result
      | _ -> ()
    done ;
    print_endline filepath ;
    !result
  with End_of_file -> close_in ic ; List.rev !result

let read_comment_mark_map filepath = Yojson.Basic.from_file filepath

let get_comment_mark json ~lang =
  let open Yojson.Basic.Util in
  let json_obj = json |> member lang in
  match json_obj with
  | `List _ -> json_obj |> to_list |> filter_string
  | `String s -> [s]
  | _ -> []

let rec get_all_file dir =
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

let run_code dir comm_dict_path =
  let open List in
  let all_files = get_all_file dir in
  let comment_map = read_comment_mark_map comm_dict_path in
  map
    (fun file ->
      let filetype = Filename.extension file in
      let comment_marks = get_comment_mark comment_map ~lang:filetype in
      pickout_from_file file comment_marks )
    all_files

(* need fix keyword accidentally appear in code *)
(* need shell argument parser *)
(* need add keyword filter in run_code *)

(* below is tiny test *)
let () =
  let result = List.nth (run_code "../codeitlater/src" "./comments.json") 3 in
  let _ =
    List.map
      (fun x ->
        match x.cmb with
        | Content s -> Printf.printf "%d:%s\n" x.linenum s
        | _ -> () )
      result
  in
  ()
