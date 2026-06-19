(*16.删除前n个元素*)
let rec drop n lst=
  if n<=0 then lst
  else begin
    match n,lst with 
    | 1,x::t -> t
    | _,x::t -> drop (n-1) t 
    | _,[] -> []
  end 

let () =
  let result=drop 3 [1;2;3;4;5] in
  List.iter (fun x -> Printf.printf "%d " x) result 
