(*28消除连续重复元素*)
let rec compress lst=
  let rec aux acc lst=
  match lst with
  | [] -> List.rev acc
  | [x] -> List.rev (x::acc)
  | a::(b::t as l) -> if a=b then aux acc l
  else aux (a::acc) l 
in aux [] lst 


let compress1 lst =
  let rec aux acc l =
    match l with
    | [] -> List.rev acc
    | x :: t -> 
        (* 如果 acc 的车头和当前元素 x 一样，说明 x 是连续重复的，直接丢弃 x 往下走 *)
        match acc with
        | head :: _ when head = x -> aux acc t
        | _ -> aux (x :: acc) t (* 否则说明 x 是新面孔，纳入口袋 *)
  in 
aux [] lst

let () =
  let result=compress [1;1;2;2;5] in
  List.iter (Printf.printf "%d ")result 