module type Key = sig
  type t
  val equal : t -> t -> bool
  val compare : t -> t -> int
  val hash : t -> int
end

module Make (K : Key) : sig
  include Hashtbl.S with type key = K.t

  val update : 'a t -> key -> ('a option -> 'a option) -> unit
  (** [update tbl x f m] updates the binding of [x] in [tbl].
      Depending on the value of [y] where y is [f (find_opt x m)], 
      the binding of [x] is added, removed or updated. 
      If [y] is [None], the binding is removed if it exists; otherwise, 
      if [y] is [Some z] then[x] is associated to [z] in the table. 
      If [x] was already bound in [tbl] to a value that is physically equal 
      to [z], [tbl] is left unchanged *)

  val add_if_absent: 'a t -> key -> 'a -> unit
  (** [add_if_absent tbk k v] adds a binding of [k] to [v] in [tbl]
      if [k] is not already bind in [tbl], otherwise raises 
      Already_present. *)

  val update_if_present: 'a t -> key -> 'a -> unit
  (** [update_if_present tbk k v] replaces the binding of [k] in [tbl]
      with [v] if [k] is already bind in [tbl], otherwise 
      raises Not_found. *)

  val exists: (key -> 'a -> bool) -> 'a t -> bool
  (** [exists p tbl checks] if at least one binding of [tbl] satisfies the      
      predicate p. *)

  val unsorted_keys : 'a t -> key list
  val keys : 'a t -> key list

  val iter_range: (key -> 'a -> unit) -> 'a t -> key -> key -> unit
  val iter_inclusive_range: (key -> 'a -> unit) -> 'a t -> key -> key -> unit
  val carve_inclusive_range: 'a t -> key -> key -> (key * 'a) list
  val min_binding: 'a t -> key * 'a
  val max_binding: 'a t -> key * 'a
  val find_first_opt: 'a t -> key -> (key * 'a) option
  val find_last_opt: 'a t -> key -> (key * 'a) option
  val find_first: 'a t -> key -> (key * 'a)
  val find_last: 'a t -> key -> (key * 'a)
  val split_off_after: 'a t -> key -> 'a t
  val swap: 'a t -> 'a t -> unit
end