(*进行过尾递归优化的版本1*)
let rec length sum lst=
    match lst with
    | [] -> sum
    | _ :: t -> length (sum+1) t

let () =
  Printf.printf "source2 长度: %d\n" (length 0 [1; 2; 3; 4; 5])