(*21.合并两个无序整数列表*)
let rec merge_unsorted lst1 lst2=
  let lst3=List.sort compare lst1 in
  let lst4=List.sort compare lst2 in
  let rec aux acc lst3 lst4=
  match lst3,lst4 with
  | [],[] -> List.rev acc
  | [],x::t -> aux (x::acc) [] t 
  | x::t,[] -> aux (x::acc) t []
  | x1::t1,x2::t2 -> if x1<=x2 then aux (x1::acc) t1 lst4
  else aux (x2::acc) lst3 t2
in aux [] lst3 lst4 

let rec print_int_list lst=
  print_string "[";
  let rec aux lst=
  match lst with
  | [] -> ()
  | [x] -> Printf.printf "%d" x 
  | x::t -> Printf.printf "%d;"x;aux t 
in aux lst;
  print_string "]"

let () =
  let result=merge_unsorted [5;3;1] [6;4;2] in
  print_int_list result