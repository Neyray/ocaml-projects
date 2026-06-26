let reachable_count (edges : (int * int) list) (n : int) (k : int) : int =
  (* 1. 建邻接表：graph.(u) = u 的所有后继节点 *)
  let graph = Array.make (n + 1) [] in
  List.iter (fun (u, v) -> graph.(u) <- v :: graph.(u)) edges;

  (* 2. visited 标记去重；count 统计访问到几个 *)
  let visited = Array.make (n + 1) false in
  let count = ref 0 in

  (* 3. DFS *)
  let rec dfs u =
    if not visited.(u) then begin
      visited.(u) <- true;
      incr count;
      List.iter dfs graph.(u)      (* 递归访问每个后继 *)
    end
  in
  dfs k;
  !count