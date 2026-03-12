let rec list_max lst =
  match lst with
   | [] -> failwith "empty list!"
   | [x] -> x
   | h :: t -> max h (list_max t)
   (*绑定变量，这个模式会将列表的第一个元素赋值（绑定）给
   变量 h（代表 head），并将剩余列表绑定给变量 t（代表 tail）。当需要用
   到第一个元素的值时，就会使用它。*)

let () =
  Printf.printf "列表最大值: %d\n" (list_max [1; 9; 4; 7])