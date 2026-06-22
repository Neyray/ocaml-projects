(*23.插入排序*)
let rec insert_sorted n lst=
  let rec aux acc n lst=
  match lst with
  | [] -> List.rev (n::acc)
  | x::t -> if x<=n then aux (x::acc) n t
  else (List.rev (n::acc)) @ lst
in aux [] n lst 

let rec insertion_sort lst=
  let rec aux acc lst=
  match lst with
  | [] -> acc(*！！！已经排好序了*)
  | x::t ->
    let new_acc=insert_sorted x acc in
    aux new_acc t 
  in aux [] lst 

let rec print_int_list lst=
  print_string "[";
  let rec aux lst=
  match lst with
  | [] -> ()
  | [x] -> Printf.printf "%d" x 
  | x::t -> Printf.printf "%d;" x;
  aux t
in aux lst ;
  print_string "]"

let () =
  let result=insertion_sort [5;1;5;2;3] in
  print_int_list result 