(*检查列表中的所有元素是否都满足 𝑝 指定的条件*)
let rec for_all p lst =
  match lst with
    | [] -> true
    | head :: tail -> (p head) && (for_all p tail)
    (*如果 p head 的结果是 false，OCaml 根本不会去计算右边的 for_all p tail，直接返回false了*)

let is_positive x = x > 0
let is_even x =x mod 2 = 0

let()=
  let r1 = for_all is_positive [1;2;3] in
  let r2 =for_all is_even [2;4;7] in
  let r3 =for_all is_positive [] in

  (* %b 对应布尔值，\n 表示换行 *)
  Printf.printf "r1 (all positive [1;2;3]): %b\n" r1;
  Printf.printf "r2 (all even [2;4;7]): %b\n" r2;
  Printf.printf "r3 (all positive []): %b\n" r3