(*42.相邻差分*)
let rec diff lst=
  let n=List.length lst in
  if n=0 then []
  else if n=1 then []
  else begin
    let rec aux acc lst=
    match lst with 
    | [] -> List.rev acc
    | [x] -> List.rev acc
    | a::(b::_ as l) -> aux ((b-a)::acc) l
  in aux [] lst end

let () =
  let result=diff [1;2;4;1] in
  List.iter (Printf.printf "%d ")result