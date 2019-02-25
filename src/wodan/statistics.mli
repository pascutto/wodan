(** The type for statistics logs *)
type t

val empty : t
(** Empty statistics (all zeros) *)

val inserts : t -> int
(** The number of calls to [incr_inserts] *)

val lookups : t -> int
(** The number of calls to [incr_lookups] *)

val range : t -> int
(** The number of calls to [incr_range] *)

val iters : t -> int
(** The number of calls to [incr_iters] *)

val incr_inserts : t -> unit

val incr_lookups : t -> unit

val incr_range : t -> unit

val incr_iters : t -> unit

val log : t -> unit
(** Logs the contents of the statistics using Logs.info *)
