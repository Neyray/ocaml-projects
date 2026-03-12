(*map可以用来对列表进行整体操作，生成新的列表*)
let rec map f lst=
    match lst with
    | [] -> []
    | h :: t -> f h :: map f t

let () =
  (* 测试将列表中每个元素乘以 2 *)
  let result = map (fun x -> x * 2) [1; 2; 3] in
  Printf.printf "map 后的列表: [ ";
  List.iter (fun x -> Printf.printf "%d " x) result;
  Printf.printf "]\n"