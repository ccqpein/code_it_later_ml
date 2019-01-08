type argv =
  {dir: string; keyword: string option; mark_table_path: string option}

let rec handle_argvs ?(re = {dir= "."; keyword= None; mark_table_path= None})
    (argvs : string list) =
  match argvs with
  | [] -> re
  | "-keyword" :: y :: xs -> handle_argvs xs ~re:{re with keyword= Some y}
  | "-k" :: y :: xs -> handle_argvs xs ~re:{re with keyword= Some y}
  | "-d" :: y :: xs -> handle_argvs xs ~re:{re with dir= y}
  | "-j" :: y :: xs -> handle_argvs xs ~re:{re with mark_table_path= Some y}
  | _ -> re

let default_json_string =
  "{\".clj\" : \";\", \".go\" : [\"//\",\"/\\\\*\"],\".py\" : \"#\",\".lisp\" \
   : \";\",\".hs\":\"-- \",\".rs\":[\"//\",\"/*\"],\".el\":\";\"}"
