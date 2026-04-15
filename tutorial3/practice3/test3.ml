module type Map = sig
 (** [('k, 'v) t] 是一个映射的类型，它将键（'k 类型）绑定到值（'v 类型）。 *)
 type ('k, 'v) t

 (** [empty] 表示一个不包含任何键的映射。 *)
 val empty : ('k, 'v) t

 (** [insert k v m] 返回一个新的映射，其中 [k] 绑定到 [v]，并且包含 [m] 中的所有绑定。
 如果 [k] 在 [m] 中已经有绑定，则新映射中 [k] 的绑定将被 [v] 替代。 *)
 val insert : 'k -> 'v -> ('k, 'v) t -> ('k, 'v) t

 (** [lookup k m] 返回在映射 [m] 中与键 [k] 绑定的值。
 如果 [k] 在 [m] 中没有绑定，则会引发 [Not_found] 异常。 *)
 val lookup : 'k -> ('k, 'v) t -> 'v

 (** [bindings m] 返回一个关联列表，该列表包含 [m] 中所有的绑定关系。
 该列表中的键保证是唯一的。 *)
 val bindings : ('k, 'v) t -> ('k * 'v) list
end

module MyMap : Map = struct
  (* 用关联列表实现：每个元素是 (键, 值) 的元组 *)
  (*将这个t实例化为list*)
  type ('k, 'v) t = ('k * 'v) list

  (* 空映射就是空列表 *)
  let empty = []

  (* insert：先过滤掉旧的同名键，再把新键值对加到头部 *)
  let insert k v m =
    let m' = List.filter (fun (k', _) -> k' <> k) m in
    (k, v) :: m'


  (* lookup：在列表里找第一个键匹配的，找不到抛 Not_found *)
  let lookup k m =
    match List.find_opt (fun (k', _) -> k' = k) m with
    | Some (_, v) -> v
    | None        -> raise Not_found

    
  (* bindings：直接返回列表本身即可，insert 已保证键唯一 *)
  let bindings m = m
end

let () =
  let m = MyMap.empty in
  let m = MyMap.insert "a" 1 m in
  let m = MyMap.insert "b" 2 m in
  let m = MyMap.insert "c" 3 m in
  Printf.printf "%d\n" (MyMap.lookup "b" m);  (* 2 *)
  Printf.printf "%d\n" (MyMap.lookup "a" m);  (* 1 *)
  let bs = MyMap.bindings m in
  List.iter (fun (k, v) -> Printf.printf "(%s, %d) " k v) bs;
  print_newline ();
  (* 测试 Not_found *)
  try let _ = MyMap.lookup "beta" m in ()
  with Not_found -> print_endline "Exception: Not_found."