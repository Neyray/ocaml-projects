(*36.列表左旋*)
let rec rotate_left lst n=
  let n=if n>List.length lst then n mod List.length lst
  else n in

  let rec aux acc lst n=
  match lst,n with
  | [],_ -> List.rev acc
  | x::t,0 -> lst @ (List.rev acc)
  | x::t,_ -> aux (x::acc) t (n-1)
in aux [] lst n 

let () =
  let result=rotate_left [1;2;3;4;5] 2 in
  List.iter (Printf.printf "%d ")result 
