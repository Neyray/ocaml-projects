(*35删除每第n个元素*)
let rec drop_every lst n=
  let rec aux acc lst count n=
  match count,lst with
  | _,[] -> List.rev acc
  | c,x::t -> if c mod n=0 then aux acc t (count+1) n
  else aux (x::acc) t (count+1) n in
  aux [] lst 1 n 

let () =
  let result=drop_every [1;2;3;4;5] 2 in
  List.iter (Printf.printf "%d ")result 