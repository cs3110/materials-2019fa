# Proofs from lecture

## Length and Append

```
Theorem:  forall xs ys, 
  length (xs @ ys) = length xs + length ys

Proof.  by induction on xs.
P(xs) = forall ys, length (xs @ ys) = length xs + length ys

Base case: xs = []
Show: forall ys, length ([] @ ys) = length [] + length ys

  length ([] @ ys)
=   { evaluation }
  length ys

  length [] + length ys
=   { evaluation }
  0 + length ys
=   {algebra}
  length ys

Inductive case: xs = h :: t
(* pause here for iclicker:  what is the IH? *)
IH:  forall ys, length (t @ ys) = length t + length ys
Show:  forall ys, length ((h :: t) @ ys) = length (h :: t) + length ys

  length ((h :: t) @ ys)
=   { evaluation of @ }
  length (h :: (t @ ys))
=   { evaluation of length }
  1 + length (t @ ys)
=   { IH }
  1 + length t + length ys

  length (h :: t) + length ys
=   { evaluation }
  1 + length t + length ys

QED
```

## Map and compose

```
Theorem:  forall f g,
  (map f) << (map g) = map (f << g)

Proof.

By extensionality, we need to show:
forall lst, ((map f) << (map g)) lst = map (f << g) lst

  ((map f) << (map g)) lst 
=   { eval << }
  (map f) ((map g) lst)
=   { remove parens }
  map f (map g lst)

So we need to show:
forall lst, map f (map g lst) = map (f << g) lst

We do so by induction on lst.
P(lst) = map f (map g lst) = map (f << g) lst

Base case: lst = []
Show: map f (map g []) = map (f << g) []

  map f (map g [])
=   { eval }
  map f []
=   { eval }
  []

  map (f << g) []
=   { eval }
  []

Inductive case:  lst = h :: t
IH: map f (map g t) = map (f << g) t
Show:  Show: map f (map g (h :: t)) = map (f << g) (h :: t)

  map f (map g (h :: t))
=   { eval inner map }
  map f (g h :: map g t)
=   { eval outer map }
  f (g h) :: map f (map g t)
=   { IH }
  f (g h) :: map (f << g) t

  map (f << g) (h :: t)
=   { eval map }
  (f << g) h :: map (f << g) t
=   { eval first << }
  f (g h) :: map (f << g) t

QED
```

## Leaves and nodes

```
Theorem:  forall t, leaves t = 1 + nodes t

Proof: by induction on t
P(t) = leaves t = 1 + nodes t

Base case:  t = Leaf
Show: leaves Leaf = 1 + nodes Leaf

  leaves Leaf
=   { eval }
  1

  1 + nodes Leaf
=   { eval }
  1 + 0
=   { algebra }
  1

Inductive case:  t = Node (l, v, r)
IH1:  leaves l = 1 + nodes l
IH2:  leaves r = 1 + nodes r
Show:  leaves (Node (l, v, r)) = 1 + nodes (Node (l, v, r))

  leaves (Node (l, v, r))
=   { eval }
  leaves l + leaves r
=   { IH1 }
  1 + nodes l + leaves r
=   { IH 2}
  1 + nodes l + 1 + nodes r
=   { algebra }
  2 + nodes l + nodes r

  1 + nodes (Node (l, v, r))
=   { eval }
  1 + 1 + nodes l + nodes r
=   { algebra }
  2 + nodes l + nodes r

QED
```