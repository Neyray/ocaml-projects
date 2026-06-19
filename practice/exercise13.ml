(*13.判断元素是否存在*)
let rec mem n lst=
 match lst with 
 | [] -> false
 | x::t -> if x=n then true
 else mem n t

let () =
  let result=mem 5 [1;2;3;4;5] in 
  match result with
  | true -> Printf.printf "true"
  | false -> Printf.printf "false"