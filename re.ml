#require "Str";;

type crumb =
  |Nothing
  |Content of string
  |Content_with_keyword of string * string;;

let pick_comment_out (sym:string) ~line:(line:string) : crumb=
  let reg = (Str.regexp (sym ^ ":=")) in
  match Str.split reg (Str.global_replace (Str.regexp "[\r\n\t ]") "" line) with
  |a::_ -> Content a
  |_ -> Nothing;;

