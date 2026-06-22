(*20.合并两个有序列表*)
let rec merge_sorted lst1 lst2=
  let rec aux acc lst1 lst2=
  match lst1,lst2 with
  | [],[] -> List.rev acc
  | [],x::t -> aux (x::acc) [] t
  | x::t,[] -> aux (x::acc) t []
  | x1::t1,x2::t2 -> if x1<=x2 then aux (x1::acc) t1 lst2
  else aux (x2::acc) lst1 t2 
in aux [] lst1 lst2

let print_int_list lst=
  print_string "[";
  let rec aux lst=
  match lst with
  | [] -> ()   (*！！！()表示什么都不用做，直接返回*)
  | [x] -> Printf.printf "%d" x
  | x::t -> Printf.printf "%d;" x; aux t
in aux lst;
  print_string "]"

let () =
  let result=merge_sorted [1;3;5;7] [2;4;6;8] in
  print_int_list result 