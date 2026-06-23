(* 41. 统计连续子序列 [1;2;3] *)
let count_123 lst =
  let rec aux acc l =
    match l with
    | 1 :: (2 :: 3 :: _ as next) -> aux (acc + 1) next
    (* 兜底：只要不是完美的 1::2::3 开头，一律只消耗掉最前面的一个元素 x *)
    | _ :: t -> aux acc t
    (* 列表彻底空了，返回计数 *)
    | [] -> acc
  in 
  aux 0 lst 

let () =
  let result = count_123 [1;2;3;4;5;6;7;8;9;1;2;3] in
  Printf.printf "%d\n" result
  (* 正确输出: 2 *)