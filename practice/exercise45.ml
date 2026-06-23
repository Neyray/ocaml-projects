(*45.删除所有重复元素，只保留第一次出现*)
let rec dedup_all lst=
  let rec find target lst=
  match lst with
  | [] -> false
  | x::t -> if x<>target then find target t
  else true in

  let rec aux acc lst=
  match lst with
  | [] -> List.rev acc
  | x::t -> let bl=find x acc in
  if bl=true then aux acc t
  else aux (x::acc) t in aux [] lst 

let () =
  let result=dedup_all [1;2;2;5;7;7;1;1;3] in
  List.iter (Printf.printf "%d")result 