(*46.统计频率*)
(*看到一个数字，先看它在不在acc里面，如果在说明之前统计过了，不用管；如果不在，统计之后的列表，数次数*)
(*核心：列表不能在原地修改*)
let rec frequency lst=
  let rec count num target lst=
  match lst with
  | [] -> num
  | x::t -> if x<>target then count num target t
  else count (num+1) target t in

  let rec find target lst=
  match lst with
  | [] -> false
  | (x,y)::t -> if x<>target then find target t
  else true in

  let rec aux acc lst=
  match lst with
  | [] -> List.rev acc
  | x::t -> let bl=find x acc in
  if bl=false then 
    let num=count 0 x t in aux ((x,num+1)::acc) t
else aux acc t in
aux [] lst

let rec print_result lst=
  match lst with
  | [] -> ()
  | [(x,y)] -> Printf.printf "(%d,%d)"x y
  | (x,y)::t -> Printf.printf "(%d,%d);"x y ;print_result t

let () =
  let result=frequency [1;2;1;1] in
  print_result result