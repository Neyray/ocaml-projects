(* Pokemon 模块签名 *)
module type Pokemon = sig
  val name      : string
  val hp        : int ref
  val attack    : int
  val take_damage : int -> unit
end

(* 皮卡丘 *)
module Pikachu : Pokemon = struct
  let name   = "Pikachu"
  let hp     = ref 35
  let attack = 55
  let take_damage dmg = hp := !hp - dmg(*:=表示给hp赋值，！是解引用*)
end

(* 小火龙 *)
module Charmander : Pokemon = struct
  let name   = "Charmander"
  let hp     = ref 39
  let attack = 52
  let take_damage dmg = hp := !hp - dmg
end

(* Battle 函子：接受两个 Pokemon 模块，返回含 fight 和 print_winner 的模块 *)
module Battle (P1 : Pokemon) (P2 : Pokemon) = struct

  (* 一轮：P1 攻击 P2，P2 攻击 P1 *)
  let fight () =
    (* loop：无返回值（unit），递归是为了重复执行 *)
    let rec loop () =
      if !P1.hp <= 0 || !P2.hp <= 0 then ()  (* 有一方倒下就停 *)
      else begin
        P2.take_damage P1.attack;  (* P1 先攻击 P2 *)
        if !P2.hp <= 0 then ()     (* P2 倒下就停，不让 P2 反击 *)
        else begin
          P1.take_damage P2.attack; (* P2 反击 P1 *)
          loop ()
        end
      end
    in
    loop ()
    (* 不需要往回收集，做完就继续，直到停止条件满足 *)
    (* factorial n = n*factorial n-1 是递归到底，再往回"收集"结果 *)

  let print_winner () =
    if !P1.hp <= 0 then
      Printf.printf "%s wins!\n" P2.name
    else
      Printf.printf "%s wins!\n" P1.name
end

(* 使用 *)
module PikachuVsCharmander = Battle (Pikachu) (Charmander)

let () =
  PikachuVsCharmander.fight ();
  PikachuVsCharmander.print_winner ()