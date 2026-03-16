(*尾递归版*)
(*求一个列表中最大的数*)
let rec list_max_iter lst =
  match lst with
  | [] -> invalid_arg "Empty list"
  (*列表匹配不能像函数定义那样直接在模式里写类型标注*)
  | h:: t ->
    let rec aux curr_max lst =
      match lst with
      | [] ->curr_max
      | x :: xs -> aux (max curr_max x) xs
    in
    (*h是从原始列表中剥离出来的具体数值*)
    aux h t