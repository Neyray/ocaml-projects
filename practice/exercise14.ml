(*14.判断两个列表是否相等*)
let rec equal_list eq lst1 lst2=
  match lst1,lst2 with
  | [],[] -> true
  | a::t1,b::t2 -> if eq a b then equal_list eq t1 t2
  else false
  | _,_ -> false

let () =
  let result=equal_list (=) [1;2;3] [1;2;3] in 
  match result with 
  | true -> print_string "true";print_newline();
  | false -> print_string "false";print_newline();