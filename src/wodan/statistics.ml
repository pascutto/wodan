type t = {
  mutable inserts : int;
  mutable lookups : int;
  mutable range_searches : int;
  mutable iters : int
}

let empty = {inserts = 0; lookups = 0; range_searches = 0; iters = 0}

let inserts t = t.inserts

let lookups t = t.lookups

let range t = t.range_searches

let iters t = t.iters

let incr_inserts t = t.inserts <- succ t.inserts

let incr_lookups t = t.lookups <- succ t.lookups

let incr_range t = t.range_searches <- succ t.range_searches

let incr_iters t = t.iters <- succ t.iters

let log t =
  Logs.info (fun m ->
      m "Statistics log : %d inserts, %d lookups, %d range searches, %d iters"
        t.inserts t.lookups t.range_searches t.iters )
