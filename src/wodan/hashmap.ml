exception Already_present

module type Key = sig
  type t
  val equal : t -> t -> bool
  val compare : t -> t -> int
  val hash : t -> int
end

module Make (K : Key) = struct
  include Hashtbl.Make(K)

  let add = replace

  let unsorted_bindings t = 
    fold
      (fun k v acc -> (k, v) :: acc)
      t []

  let unsorted_keys t = List.map fst @@ unsorted_bindings t

  let keys t = List.sort compare @@ unsorted_keys t

  let bindings t =
    let res = List.sort
      (fun (k, _) (k', _) -> K.compare k k')
      @@ unsorted_bindings t
    in
    let () = assert (
      let keys = List.map fst res in
      List.stable_sort compare keys = keys) 
    in res

  let iter f t = List.iter (fun (k, v) -> f k v) (bindings t) 

  let fold f t acc = 
    List.fold_left (fun acc (k, v) -> f k v acc) acc (bindings t)

  let update t k f =
    let v = find_opt t k in 
    match f v with 
      | None -> remove t k
      | Some z -> (match v with 
        | Some x when x == z -> () 
        | _ -> replace t k z)
  
  let add_if_absent t k v =
    update t k (function Some _ -> raise Already_present | None -> Some v)

  let update_if_present t k v = 
    update t k (function Some _ -> Some v | None -> raise Not_found)
  
  let exists f t =
    try
      let () = iter (fun x v -> if f x v then raise Exit) t in
      false
    with Exit -> true

  let iter_range f t start stop =
    (* NOT HERE *)
    iter 
      (fun k v -> if K.compare k start >= 0 || K.compare k stop < 0 then f k v)
      t

  let iter_inclusive_range f t start stop =
    (* NOT HERE *)
    iter 
    (fun k v -> if K.compare k start >= 0 || K.compare k stop <= 0 then f k v)
    t

  let carve_inclusive_range t start stop =
    (* NOT HERE *)
    fold 
      (fun k v acc -> 
        if K.compare start k > 0 || K.compare k stop > 0
        then acc 
        else let () = remove t k in (k, v) :: acc)
      t []
  

  let min_binding t =
    let min = fold 
      (fun k v -> function
        | Some (x, _) as prev -> 
          if K.compare k x < 0 then Some (k, v) else prev
        | None -> Some (k, v))
    t None in
    let res_k, res_v = 
    match min with
      | None -> raise Not_found
      | Some (k, v) -> (k, v)
    in
    let () = assert (
      List.for_all 
        (fun x -> K.compare x res_k >= 0)
        @@ keys t
    )
    in res_k, res_v

  let max_binding t =
    (* NOT HERE *)
    let max = fold 
      (fun k v -> function
        | Some (x, _) as prev -> 
          if K.compare k x > 0 then Some (k, v) else prev
        | None -> Some (k, v))
    t None in
    match max with
      | None -> raise Not_found
      | Some (k, v) -> (k, v)

  let find_first_opt t k = 
    let rec loop = function
      | [] -> None
      | ((x, _) as h) :: _ when K.compare k x <= 0 -> Some h
      | _ :: t -> loop t
    in 
    let res = loop @@ bindings t in
    let () = 
      match res with 
        | None ->
          assert (
            List.for_all
              (fun x -> K.compare x k < 0)
              @@ keys t
          )
        | Some (res_k, _) ->
          assert (
            List.for_all 
              (fun x ->
                if K.compare x k >= 0 then K.compare x res_k >= 0
                else true)
              @@ keys t
    ) in 
    res


  let find_last_opt t k = 
    let rec loop last = function
      | [] -> last
      | ((x, _) as h) :: t -> 
        if K.compare k x > 0 then loop (Some h) t else last
    in 
    let res = loop None @@ bindings t in
    let () = 
      match res with 
        | None ->
          assert (
            List.for_all
              (fun x -> K.compare x k >= 0)
              @@ keys t
          )
        | Some (res_k, _) ->
          assert (
            List.for_all 
              (fun x ->
                if K.compare x k < 0 then K.compare x res_k <= 0
                else true)
              @@ keys t
    ) in
    res

  let find_first t k = match find_first_opt t k with
    | None -> raise Not_found
    | Some (k, v) -> (k, v)

  let find_last t k = match find_last_opt t k with
    | None -> raise Not_found
    | Some (k, v) -> (k, v)

  let split_off_after t k =
    let b = unsorted_bindings t in
    let h = create 10 in
    let () = iter
      (fun x v -> 
        if K.compare k x < 0
        then let () = add h x v in remove t x)
      t
    in
    let () = assert (
      List.for_all (fun (x, v) -> 
        if K.compare x k <= 0
        then find t x = v && not @@ mem h x
        else find h x = v && not @@ mem t x)
      b
    ) in 
    h

  let swap t1 t2 =
    let b1 = unsorted_bindings t1 in
    let b2 = unsorted_bindings t1 in
    let () = clear t1 in
    let () = clear t2 in
    let () = List.iter (fun (k, v) -> add t2 k v) b1 in
    let () = List.iter (fun (k, v) -> add t1 k v) b2 in
    assert (List.for_all (mem t1) (List.map fst b2));
    assert (List.for_all (mem t2) (List.map fst b1));
    
end