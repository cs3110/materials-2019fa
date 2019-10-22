module type Map = sig
  (** [('k, 'v) t] is the type of maps that bind keys of type
      ['k] to values of type ['v]. *)
  type ('k, 'v) t

  (** [empty] is the empty map *)
  val empty : ('k, 'v) t

  (** [insert k v m] is the same map as [m], but with an additional
      binding from [k] to [v].  If [k] was already bound in [m],
      that binding is replaced by the binding to [v] in the new map. *)
  val insert : 'k -> 'v -> ('k, 'v) t -> ('k, 'v) t

  (** [find k m] is [Some v] if [k] is bound to [v] in [m],
      and [None] if not. *)
  val find : 'k -> ('k, 'v) t -> 'v option

  (** [remove k m] is the same map as [m], but without any binding of [k].
      If [k] was not bound in [m], then the map is unchanged. *)
  val remove : 'k -> ('k, 'v) t -> ('k, 'v) t

  (** [bindings m] is an association list containing the same
      bindings as [m]. *)
  val bindings : ('k, 'v) t -> ('k * 'v) list

  (** [of_list lst] is a map containing the same bindings as
      association list [lst]. 
      Requires: [lst] does not contain any duplicate keys. *)
  val of_list : ('k * 'v) list -> ('k, 'v) t

end

module AssocListMap : Map = struct
  (** AF: [[k1,v1; k2,v2; ...; kn,vn]] is the map {k1:v1, k2:v2, ..., kn:vn}.
      If a key appears more than once in the list, then in the map it is
      bound to the left-most occurrence in the list---e.g., [[k, v1; k, v2]]
      is the map {k:v1}.  The empty list represents the empty map.
      RI: none. *)
  type ('k, 'v) t = ('k * 'v) list

  let empty = []

  (** Efficiency: O(1) *)
  let insert k v m = (k, v) :: m

  (** Efficiency: O(n) *)
  let find = List.assoc_opt

  (** Efficiency: O(n) *)
  let remove k lst = List.filter (fun (k',_) -> k <> k') lst

  (** [keys m] is a set-like list of the keys in [m]. 
      Efficiency: O(n log n). *)
  let keys m = 
    m |> List.map fst |> List.sort_uniq Stdlib.compare

  (** [binding m k] is (k, v), where [v] is the value that [k]
      binds in [m].
      Requires: [k] is a key in [m]. 
      Efficiency: O(n) *)
  let binding m k = 
    (k, List.assoc k m)

  (** Efficiency: O(n^2) *)
  let bindings m =
    List.map (binding m) (keys m)
  (* [keys m] is O(n log n) and produces a list of length O(n).
     [binding m] is O(1) to just partially apply. 
     Calling [binding m] on every element of [keys m] is
       O(n) work for each of O(n) elements.
     Total: O(n log n) + O(n)*O(n), 
       which is O(n^2). *)

  (** Efficiency: O(1) *)
  let of_list lst = lst
end

module type DirectAddressMap = sig
  (** ['v t] is the type of mutable direct-address maps that bind keys of type
      [int] to values of type ['v]. *)
  type 'v t

  (* [create c] creates a new map with capacity [c]. Keys [0] through [c-1]
     are _in bounds_ for the map. *)
  val create : int -> 'v t

  (**[insert k v m] mutates map [m] to bind [k] to [v].  If [k] was already
     bound in [m], that binding is replaced by the binding to [v]. 
     Requires: [k] is in bounds. *)
  val insert : int -> 'v -> 'v t -> unit

  (** [find k m] is [Some v] if [k] is bound to [v] in [m],
      and [None] if not. 
      Requires: [k] is in bounds. *)
  val find : int -> 'v t -> 'v option

  (** [remove k m] mutates [m] to remove any binding of [k].
      If [k] was not bound in [m], then the map is unchanged.
      Requires: [k] is in bounds. *)
  val remove : int -> 'v t -> unit

  (** [bindings m] is an association list containing the same bindings
      as [m]. *)
  val bindings : 'v t -> (int * 'v) list

  (** [of_list c lst] creates a map with the same bindings as [m] and with
      capacity [c].
      Requires: [lst] does not contain any duplicate keys, and every key
      in [m] is in bounds. *)
  val of_list : int -> (int * 'v) list -> 'v t
end

module ArrayMap : DirectAddressMap = struct
  (** AF: [|Some v0; Some v1; ...|]] represents {0:v0, 1:v1, ...}.
          But if element [i] of [a] is None, then [i] is not bound in the map.
      RI: None *)
  type 'v t = 'v option array

  (** Efficiency: O(n) *)
  let create n =
    Array.make n None

  (** Efficiency: O(1) *)
  let insert k v a =
    a.(k) <- Some v

  (** Efficiency: O(1) *)
  let find k a =
    a.(k)

  (** Efficiency: O(1) *)
  let remove k a =
    a.(k) <- None

  (** Efficiency: O(n) *)
  let bindings a =
    let bs = ref [] in
    for k = 0 to Array.length a do   (* n repetitions *)
      match a.(k) with  (* O(1) *)
      | None -> ()
      | Some v -> bs := (k, v) :: !bs  (* O(1) *)
    done;  (* so whole loop is O(n) *)
    !bs

  (** Efficiency: O(n) *)
  let of_list c lst =
    let m = create c in  (* O(n) *)
    List.iter (fun (k, v) -> insert k v m) lst;
    (* O(1) work O(n) times is O(n) *)
    m

end

module type TableMap = sig
  (* [('k, 'v) t] is the type of mutable table-based maps that bind keys of type
   * ['k] to values of type ['v]. *)
  type ('k, 'v) t

  (* [create hash c] creates a new table map with capacity [c]
   * that will use [hash] as the function to convert keys to integers.
   * requires: the output of [hash] is always non-negative. *)
  val create : ('k -> int) -> int -> ('k, 'v) t

  (* [insert k v m] mutates map [m] to bind [k] to [v].  If [k] was already
   * bound in [m], that binding is replaced by the binding to [v]. *)
  val insert : 'k -> 'v -> ('k, 'v) t -> unit

  (* [find k m] is [Some v] if [k] is bound to [v] in [m],
   * and [None] if not. *)
  val find : 'k -> ('k, 'v) t -> 'v option

  (* [remove k m] mutates [m] to remove any binding of [k].
   * If [k] was not bound in [m], then the map is unchanged. *)
  val remove : 'k -> ('k, 'v) t -> unit

  (* [bindings m] is an association list containing the same bindings as [m]. *)
  val bindings : ('k, 'v) t -> ('k * 'v) list

  (** [of_list hash lst] creates a map with the same bindings as [m], using
      [hash] as the hash function.
      Requires: [lst] does not contain any duplicate keys. *)
  val of_list : ('k -> int) -> ('k * 'v) list -> ('k, 'v) t
end

module HashMap : TableMap = struct
  (** AF:  If [buckets] is
           [|[(k11,v11); (k12,v12);...];
           [(k21,v21); (k22,v22);...]; ...|]
      that represents the map
        {k11:v11, k12:v12, ...,
         k21:v21, k22:v22, ...,  ...}.
       RI: No key appears more than once in array (so, no duplicate keys in
         association lists).  All keys are in the right buckets: if [k] is in
         [buckets] at index [b] then [hash(k) = b].  The number of bindings
         in [buckets] equals [size]. *)
  type ('k, 'v) t = {
    hash : 'k -> int;
    mutable size : int;
    mutable buckets : ('k * 'v) list array
  }

  (** [capacity tab] is the number of buckets in [tab]. 
      Efficiency: O(1) *)
  let capacity {buckets} =
    Array.length buckets

  (** [load_factor tab] is the load factor of [tab], i.e., the number of
      bindings divided by the number of buckets. *)
  let load_factor tab =
    float_of_int tab.size /. float_of_int (capacity tab)

  (** Efficiency: O(n) *)
  let create hash n =
    {hash; size = 0; buckets = Array.make n []}

  (** [index k tab] is the index at which key [k] should be stored in the
      buckets of [tab]. 
      Efficiency: O(1) *)
  let index k tab =
    (tab.hash k) mod (capacity tab)

  (** [insert_no_resize k v tab] inserts a binding from [k] to [v] in [tab]
      and does not resize the table, regardless of what happens to the
      load factor.
      Efficiency: O(L) *)
  let insert_no_resize k v tab =
    let b = index k tab in (* O(1) *)
    let old_bucket = tab.buckets.(b) in
    tab.buckets.(b) <- (k,v) :: List.remove_assoc k tab.buckets.(b); (* O(L) *)
    if List.length old_bucket != List.length tab.buckets.(b) then begin
      tab.size <- tab.size + 1 (* O(1) *)
    end else () 

  (** [rehash tab new_capacity] replaces the buckets array of [tab] with a new
      array of size [new_capacity], and re-inserts all the bindings of [tab]
      into the new array.  The keys are re-hashed, so the bindings will
      likely land in different buckets. 
      Efficiency: O(n), assuming [new_capacity] is O(n). *)
  let rehash tab new_capacity =
    (* insert (k,v) into tab *)
    let rehash_binding (k,v) =
      insert_no_resize k v tab
    in
    (* insert all bindings of bucket into tab *)
    let rehash_bucket bucket =
      List.iter rehash_binding bucket
    in
    let old_buckets = tab.buckets in
    (* O(n), assuming [new_capacity] is O(n) *)
    tab.buckets <- Array.make new_capacity []; 
    tab.size <- 0;
    (* [rehash_binding] is called by [rehash_bucket] once for every binding.
       So total running time of the [Array.iter] is O(n). *)
    Array.iter rehash_bucket old_buckets

  (* [resize_if_needed tab] resizes and rehashes [tab] if the load factor
   * is too big or too small.  Load factors are allowed to range from
   * 1/2 to 2. *)
  let resize_if_needed tab =
    let lf = load_factor tab in
    if lf > 2.0 then
      rehash tab (capacity tab * 2)
    else if lf < 0.5 then
      rehash tab (capacity tab / 2)
    else ()

  (** Efficiency: O(n) 
      (But we'll see in the next lecture how to make it O(1).) *)
  let insert k v tab =
    insert_no_resize k v tab; (* O(L) *)
    resize_if_needed tab (* O(n) *)

  (** Efficiency: O(L) *)
  let find k tab =
    List.assoc_opt k tab.buckets.(index k tab)

  (** [remove_no_resize k tab] removes [k] from [tab] and does not trigger
      a resize, regardless of what happens to the load factor. 
      Efficiency: O(L) *)
  let remove_no_resize k tab =
    let b = index k tab in
    let old_bucket = tab.buckets.(b) in
    tab.buckets.(b) <- List.remove_assoc k tab.buckets.(b);
    if List.length old_bucket != List.length tab.buckets.(b) then begin
      tab.size <- tab.size - 1
    end else ()

  (** Efficiency: O(n)
      (but like [insert], in next lecture will be made O(1).) *)
  let remove k tab =
    remove_no_resize k tab; (* O(L) *)
    resize_if_needed tab (* O(n) *)

  (** Efficiency: O(n) *)
  let bindings tab =
    Array.fold_left
      (fun acc bucket ->
         List.fold_left
           (* 1 cons for every binding, which is O(n) *)
           (fun acc (k,v) -> (k,v) :: acc) 
           acc bucket)
      [] tab.buckets

  (** Efficiency: if [insert] is O(n), [of_list] would be O(n^2).
      But after we see how to make [insert] O(1), [of_list] will be 
      just O(n). *)
  let of_list hash lst =
    let m = create hash (List.length lst) in  (* O(n) *)
    List.iter (fun (k, v) -> insert k v m) lst; (* O(n) work n times is O(n^2) *)
    m
end
