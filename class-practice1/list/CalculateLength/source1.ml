(*初始版本*)
let rec length lst=
  match lst with
   | [] -> 0
   | _ :: t -> 1 + length t
   (*通配符忽略，_是ocaml中的通配符，它会成功匹配列表的第一个元素，
   但直接丢弃/忽略它，只把剩余列表绑定给 t *)

let () =
  Printf.printf "source1 长度: %d\n" (length [1; 2; 3; 4; 5])