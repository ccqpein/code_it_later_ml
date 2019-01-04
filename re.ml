type crumb =
  | Nothing
  | Content of string
  | Content_with_keyword of string * string

let rec pick_comment_out (sym : string list) ~(line : string) : crumb =
  match sym with
  | x :: xs ->
      let reg = Str.regexp (x ^ ":= *") in
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

(* need filename and filetype separeter *)
