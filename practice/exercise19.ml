(*19.生成整数区间列表*)
let rec range a b=
  if a>b then []
  else begin
    let rec aux acc idx=
    if idx<=b then aux (idx::acc) (idx+1)
    else List.rev acc
  in aux [] a
end 

let () =
  let result = range 1 5 in
  (* 1. 将 int list 转换为 string list *)
  let str_list = List.map string_of_int result in
  (* 2. 用 "; " 连接，并加上首尾的方括号 *)
  Printf.printf "[%s]\n" (String.concat ";" str_list)