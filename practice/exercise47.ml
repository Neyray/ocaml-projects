(*47.排序去重*)
let rec sort_uniq_int lst=
  (*升序排序*)
  let rec insert_at target acc lst=
  match lst with
  | [] -> List.rev (target::acc)
  | x::t -> if x<=target then insert_at target (x::acc) t
  else (List.rev (target::acc))@lst in 

  let rec insertion_sort lst=
  let rec aux acc lst=
  match lst with
  | [] -> acc
  | x::t -> let new_acc=insert_at x [] acc in   (*acc(insert_at函数的acc)是存储结果的列表，所以一般都设为[]*)
  aux new_acc t in
aux [] lst  in

  let lst_sort=insertion_sort lst in 

  let rec compress lst=
  let rec aux acc lst=
  match lst with
  | [] -> List.rev acc
  | [x] -> List.rev (x::acc)
  | a::(b::_ as l) -> if a=b then aux acc l
  else aux (a::acc) l in aux [] lst 
in
compress lst_sort 

let () =
  let result=sort_uniq_int [3;1;2;3;1;4] in 
  List.iter (Printf.printf "%d ") result 