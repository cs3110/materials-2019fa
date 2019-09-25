module type Set = sig

  (** ['a t] is the type of a set whose elements have type ['a]. *)
  type 'a t

  (** [empty] is the empty set. *)
  val empty : 'a t

  (** [size s] is the number of elements in [s].
      [size empty] is [0]. *)
  val size : 'a t -> int

  (** [add x s] is a set containing all the elements of
      [s] as well as element [x]. *)
  val add : 'a -> 'a t -> 'a t

  (** [mem x s] is [true] iff [x] is an element of [s]. *)
  val mem : 'a -> 'a t -> bool

end

module ListSetNoDups : Set = struct
  (** AF: The list [a1; ...; an] represents the set {a1, ..., an}.
      [] represents the empty set.
      RI: The list may not contain duplicates. *)
  type 'a t = 'a list
  let empty = []
  let mem = List.mem
  let size = List.length
  let add x lst = 
    if mem x lst then lst else x :: lst
  let union lst1 lst2 = 
    lst1 @ lst2 |> List.sort_uniq Stdlib.compare
end

module ListSetDups : Set = struct
  (** AF: The list [a1; ...; an] represents the set {a1, ..., an},
      with any duplicates removed. [] represents the empty set. *)
  type 'a t = 'a list
  let empty = []
  let add x lst = x :: lst
  let mem = List.mem
  let rec size = function
    | [] -> 0
    | h :: t -> (if mem h t then 0 else 1) + size t
  (* a more efficient implementation *)
  let size' lst = 
    lst |> List.sort_uniq Stdlib.compare |> List.length
  let union lst1 lst2 = lst1 @ lst2
end


