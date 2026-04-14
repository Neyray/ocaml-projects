module type ColorType = sig
  (*specifications 是模块中项的类型注释，包括 val 声明、类型和异常的定义以及嵌套类型
定义。*)

 (* 定义颜色类型 *)
 type t
 
 (*初始颜色*)
 val red : t
 (* 将颜色转换为字符串 *)
 val to_string : t -> string
 
 (* 按顺序获取下一个颜色 *)
 val next : t -> t
end
(*注释的位置从模块里面转移到了签名里面。这些注释是签名中名称规范的合理组成部分。
它们描述了项的抽象行为。*)


module Color : ColorType = struct
 type t = Red | Green | Blue
 let red = Red
 let green = Green
 let blue = Blue
 
 let to_string = function
 | Red -> "Red"
 | Green -> "Green"
 | Blue -> "Blue"
 let next = function
 | Red -> Green
 | Green -> Blue
 | Blue -> Red
end