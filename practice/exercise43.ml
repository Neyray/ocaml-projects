(*43.前缀和*)
let rec prefix_sum lst=
  let rec aux acc count lst=
  match lst with
  | [] -> List.rev acc
  | x::t -> aux ((x+count)::acc) (count+x) t 
in aux [] 0 lst

let () =
  let result=prefix_sum [1;2;3;4] in
  List.iter (Printf.printf "%d ")result 