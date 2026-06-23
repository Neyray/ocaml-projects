(*44.相邻元素配对*)
let rec pair_wise lst=
  let rec aux acc lst=
  match lst with
  | [] -> List.rev acc
  | a::(b::_ as v) -> aux ((a,b)::acc) v
  | [x] -> List.rev acc
in aux [] lst

let () =
  let result=pair_wise [1;2;3] in
  let rec aux lst=
  match lst with
  | [] -> ()
  | [(x,y)] -> Printf.printf "(%d;%d)"x y
  | (x,y)::t -> Printf.printf "(%d;%d),"x y ;aux t in
  aux result 