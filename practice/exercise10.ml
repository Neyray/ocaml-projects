(*10.统计元素出现次数*)
let rec count n lst=
 let rec aux acc n lst=
 match lst with
 | [] -> acc
 | x::t ->
  if x=n then aux (acc+1) n t
  else aux acc n t
in aux 0 n lst 

let()=
  let result=count 2 [1;2;2;4;5] in
  Printf.printf "result:%d\n" result