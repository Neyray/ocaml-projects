(*15.取前n个元素*)
let rec take n lst =
  if n<=0 then []
  else begin
    let rec aux acc n lst=
    match n,lst with
    | 0,_ -> List.rev acc
    | _, x::t -> aux (x::acc) (n-1) t
    | _,[] -> List.rev acc
  in aux [] n lst end

let () =
  let result=take 5 [1;2;3;4;5;6] in 
  (*！！！中间想进行什么操作直接引入变量，类似C++的lambda*)
  List.iter (fun x -> Printf.printf "%d " x) result