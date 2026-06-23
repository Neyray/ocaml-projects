(*5.尾递归反转链表，必须使用尾递归辅助函数 aux acc lst，不能使用 List.rev*)
let rec reverse lst=
 let rec aux acc lst=
  match lst with
  | [] -> acc
  | x :: t -> aux (x::acc) t
in aux [] lst

let () =
  let result=reverse [1;2;3] in
  List.iter print_int result