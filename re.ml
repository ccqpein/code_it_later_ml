#require "Str";;


type crumb =
  |Nothing
  |Content of string
  |Content_with_keyword of string * string
;;


let pick_comment_out (sym:string) ~line:(line:string) : crumb =
  let reg = (Str.regexp (sym ^ ":= *")) in
  match Str.split reg line with
  |a::_ -> Content a
  |_ -> Nothing
;;


let keyword_filter keyword ~content:(x:crumb) : crumb =
match x with
  |Content c ->
    let keyword_reg = Str.regexp (keyword ^ ": *") in
    if Str.string_match keyword_reg c 0
    then Content_with_keyword ((keyword ^ ":"), List.hd (Str.split keyword_reg c))
    else x
  |_ -> x
;;


(* need json file reader *)
(* need file reader *)

