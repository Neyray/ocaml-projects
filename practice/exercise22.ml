(*22.向有序表中插入元素*)
let rec insert_sorted n lst =
  let rec aux acc n lst=
  match lst with
  | [] -> List.rev (n::acc)
  | x::t -> if x<=n then aux (x::acc) n t
  else List.rev (n::acc) @ lst 
in aux [] n lst 

let rec print_int_list lst=
  print_string "[";
  let rec aux lst=
  match lst with
  | [] -> ()
  | [x] -> Printf.printf "%d" x 
  | x::t -> Printf.printf "%d;" x; aux t 
in aux lst;
  print_string "]"


let () =
  let result=insert_sorted 5 [1;2;4;6] in
  print_int_list result 