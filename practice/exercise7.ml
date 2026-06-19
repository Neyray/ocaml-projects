(*7.对列表内的元素进行求和与求积*)
let rec sum lst=
 let rec aux acc lst=
  match lst with
 | [] -> acc
 | x :: t -> aux (acc+x) t
in aux 0 lst

let rec prod lst=
 let rec aux acc lst=
  match lst with
  | [] ->acc
  | x::t -> aux (acc*x) t
in aux 1 lst

let () =
  let result1=sum [1;2;3;4] in
  let result2=prod [1;2;3;4] in

  Printf.printf "result1:%d\n" result1;
  Printf.printf "result2:%d\n" result2
