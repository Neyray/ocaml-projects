(*模块名必须以大写开头。最好使用大驼峰命名法命名模块。*)
module Color = struct
  (*定义颜色类型*)
  type t=Red | Green | Blue

  (*初始颜色*)
  let red=Red
  let green=Green
  let blue=Blue

  (*将颜色转换为字符串*)
  let to_string=function
    | Red -> "Red"
    | Green -> "Green"
    | Blue -> "Blue"
  

  (*按顺序获取下一个颜色*)
  let next=function
    | Red -> Green
    | Green -> Blue
    | Blue -> Red
end

let red=Color.red

let()=
  print_endline(Color.to_string red);
  print_endline(Color.to_string(Color.next red))
