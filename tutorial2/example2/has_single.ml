(*判断I是否刚好包含一个元素*)
let has_single_elem lst =
    match lst with
    | [] -> false
    (*下划线表示不在乎这个元素具体是什么*)
    | [_] -> true
    | _ -> false

