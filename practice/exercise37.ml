(*37.删除指定下标元素*)
let rec remove_at n lst=
  if n<0 then lst
  else if n>List.length lst then lst 
  else begin
    let rec aux acc n lst=
    match n,lst with
    | _,[] -> List.rev acc
    | 0,x::t -> (List.rev acc)@t
    | _,x::t -> aux (x::acc) (n-1) t in aux [] n lst
  end


let () =
  let result=remove_at 2[1;2;3;4;5] in
  List.iter (Printf.printf "%d ")result 