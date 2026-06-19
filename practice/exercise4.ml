(*4.计算列表长度*)
let rec length lst =
  match lst with
  | [] -> 0
  | _ :: t -> 1+length t

let rec length_tail lst=
 let rec aux acc lst =
  match lst with
  | [] -> acc
  | _ :: t -> aux (acc+1) t
 in aux 0 lst 

(*尾递归就是要使递归是最后一步*)
let () =
  let len1 = length [1; 2; 3; 4] in
  let len2 = length [] in
  let len3 = length_tail ["a"; "b"; "c"] in

  Printf.printf "length [1;2;3;4] = %d\n" len1;
  Printf.printf "length [] = %d\n" len2;
  Printf.printf "length_tail [\"a\";\"b\";\"c\"] = %d\n" len3