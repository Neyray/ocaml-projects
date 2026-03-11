(*初始版本*)
let rec length lst=
  match lst with
   | [] -> 0
   | _ :: t -> 1+length t

