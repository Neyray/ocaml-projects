(*38.指定位置插入元素*)
let rec insert_at target n lst=
  if n<=0 then target::lst
  else if n>List.length lst then lst@[target]
  else begin
    let rec aux acc target n lst=
    match n,lst with
    | _,[] -> List.rev (target::acc)
    | 0,_ -> (List.rev (target::acc)) @ lst
    | _,x::t -> aux (x::acc) target (n-1) t
  in aux [] target n lst
end 

let () =
  let result=insert_at 99 2 [1;2;3;4] in
  List.iter (Printf.printf "%d ")result 