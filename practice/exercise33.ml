(*33.每个元素复制两次*)
let rec duplicate lst=
  let rec aux acc lst=
  match lst with
  | [] -> List.rev acc
  | x::t -> aux (x::x::acc) t
in aux [] lst 

let () =
  let result=duplicate [1;2;3] in
  List.iter (Printf.printf "%d ")result 