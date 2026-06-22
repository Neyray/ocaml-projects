(*34.每个元素复制n次*)
let rec replicate lst n=
  let rec add acc target n=
  match n with
  | 0 -> acc
  | _ -> add (target::acc) target (n-1) in

  let rec aux acc lst n=
  match lst with
  | [] -> List.rev acc
  | x::t -> let new_acc=add acc x n in
  aux new_acc t n in
  aux [] lst n 

let () =
  let result=replicate [1;2;3;4] 5 in
  List.iter (Printf.printf "%d ")result 