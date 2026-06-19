(*18.截取列表空间*)
let slice i j lst =
  let i = if i < 0 then 0 else i in          (* 处理 i < 0 的情况 *)
  if i >= j then []                          (* 处理 i >= j 的情况 *)
  else
    let rec aux acc idx remaining =
      match remaining with
      | [] -> List.rev acc                   (* 情况 1：列表提前空了 *)
      | x :: t ->
          if idx >= j then List.rev acc      (* 情况 2：超过右边界，提前结束 *)
          else if idx >= i then 
            aux (x :: acc) (idx + 1) t       (* 情况 3：在区间内，收集元素，下标+1 *)
          else 
            aux acc (idx + 1) t              (* 情况 4：还没到左边界，跳过元素，下标+1 *)
    in
    aux [] 0 lst                             (* 从下标 0 开始数起 *)

let () =
  let res1 = slice 1 4 [0; 1; 2; 3; 4; 5] in
  let res2 = slice 0 3 ["a"; "b"; "c"; "d"] in
  let res3 = slice 3 3 [1; 2; 3; 4] in
  let res4 = slice (-2) 2 [10; 20; 30] in

  let print_int_list l = List.iter (Printf.printf "%d ") l; print_newline () in
  let print_str_list l = List.iter (Printf.printf "%s ") l; print_newline () in

  print_string "res1: "; print_int_list res1; (* 输出: 1 2 3 *)
  print_string "res2: "; print_str_list res2; (* 输出: a b c *)
  print_string "res3: "; print_int_list res3; (* 输出: (空行) *)
  print_string "res4: "; print_int_list res4  (* 输出: 10 20 *)