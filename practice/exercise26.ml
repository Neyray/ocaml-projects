(*26.拍平二维列表*)
(*！！！核心：一样的分析列表中的每一个元素，只不过是列表*)
let rec flatten lst=
  let rec aux acc lst=
  match lst with
  | [] -> acc
  | x::t -> aux (acc @ x) t
in aux [] lst 

let () =
  let result1 = flatten [[1;2]; [3]; [4;5]] in
  List.iter (fun x->Printf.printf "%d " x) result1