# Proofs about Programs, Part 2

So far we've proved the correctness of recursive functions on natural numbers.
We used OCaml's `int` type as a representation of the naturals.  Of course,
that type is somewhat of a mismatch:  negative `int` values don't represent
naturals, and there is an upper bound to what natural numbers we can represent
with `int`.

## Natural Numbers

Let's fix those problems by defining our own variant to represent natural
numbers:
```
type nat = 
  | Z
  | S of nat
```

The constructor `Z` represents zero; and the constructor `S` represents the
successor of another natural number.  So, 

- 0 is represented by `Z`,
- 1 by `S Z`,
- 2 by `S (S Z)`,
- 3 by `S (S (S Z))`, 

and so forth.  This variant is thus a *unary* (as opposed to binary
or decimal) representation of the natural numbers:  the number of times `S`
occurs in a value `n : nat` is the natural number that `n` represents.

We can define addition on natural numbers with the following function:
```
let rec plus a b = 
  match a with
  | Z -> b
  | S k -> S (plus k b)
```

Immediately we can prove the following rather trivial claim:

```
Claim:  plus Z n = n

Proof:

  plus Z n
=   { evaluation }
  n

QED
```

But suppose we want to prove this also trivial-seeming claim:

```
Claim:  plus n Z = n

Proof:

  plus n Z
= 
  ???
```

We can't just evaluate `plus n Z`, because `plus` matches against its first
argument, not second.  One possibility would be to do a case analysis:
what if `n` is `Z`, vs. `S k` for some `k`?  Let's attempt that.

```
Proof:

By case analysis on n, which must be either Z or S k.

Case:  n = Z

  plus Z Z
=   { evaluation }
  Z

Case:  n = S k

  plus (S k) Z
=   { evaluation }
  S (plus k Z)
=
  ???
```

We are again stuck, and for the same reason:  once more `plus` can't be
evaluated any further.

When you find yourself needing to solve the same subproblem in programming,
you use recursion.  When it happens in a proof, you use induction!  

## Induction on nat

We need to do induction on values of type `nat`.  We'll need an induction
principle.  Here it is:
```
forall properties P,
  if P(Z),
  and if forall k, P(k) implies P(S k),
  then forall n, P(n)
```

Compare that to the induction principle we used for natural numbers before,
when we were using `int` in place of natural numbers:
```
forall properties P,
  if P(0),
  and if forall k, P(k) implies P(k + 1),
  then forall n, P(n)
```

There's no essential difference between the two: we just use `Z` in place of
`0`, and `S k` in place of `k + 1`.

Using that induction principle, we can carry out the proof:

```
Claim:  plus n Z = n

Proof: by induction on n.
P(n) = plus n Z = n

Base case: n = Z
Show: plus Z Z = Z

  plus Z Z
=   { evaluation }
  Z

Inductive case: n = S k
IH: plus k Z = k
Show: plus (S k) Z = S k

  plus (S k) Z
=   { evaluation }
  S (plus k Z)
=   { IH }
  S k

QED
```

## Lists

It turns out that natural numbers and lists are quite similar, when viewed
as data types.  Here are the definitions of both, side-by-side for comparison:
```
type 'a list =                  type nat =
  | []                            | Z
  | (::) of 'a * 'a list          | S of nat
```

Both types have a constructor representing a concept of "nothing".  Both types
also have a constructor representing "one more" than another value of the type:
`S n` is one more than `n`, and `h :: t` is a list with one more element than
`t`.

The induction principle for lists is likewise quite similar to the induction
principle for natural numbers.  Here is the principle for lists:
```
forall properties P,
  if P([]),
  and if forall h t, P(t) implies P(h :: t),
  then forall lst, P(lst)
```

An inductive proof for lists therefore has the following structure:
```
Proof: by induction on lst.
P(lst) = ...

Base case: lst = []
Show: P([])

Inductive case: lst = h :: t
IH: P(t)
Show: P(h :: t)
```

Let's try an example of this kind of proof.  Recall the definition of the
append operator:

```
let rec append lst1 lst2 =
  match lst1 with
  | [] -> lst2
  | h :: t -> h :: append t lst2

let (@) = append
```
We'll prove that append is associative.

```
Theorem: forall xs ys zs, xs @ (ys @ zs) = (xs @ ys) @ zs

Proof: by induction on xs.
P(xs) = forall ys zs, xs @ (ys @ zs) = (xs @ ys) @ zs

Base case: xs = []
Show: forall ys zs, [] @ (ys @ zs) = ([] @ ys) @ zs

  [] @ (ys @ zs)
=   { evaluation }
  ys @ zs
=   { evaluation }
  ([] @ ys) @ zs

Inductive case: xs = h :: t
IH: forall ys zs, t @ (ys @ zs) = (t @ ys) @ zs
Show: forall ys zs, (h :: t) @ (ys @ zs) = ((h :: t) @ ys) @ zs

  (h :: t) @ (ys @ zs) 
=   { evaluation }
  h :: (t @ (ys @ zs))
=   { IH }
  h :: ((t @ ys) @ zs)

  ((h :: t) @ ys) @ zs
=   { evaluation of inner @ }
  (h :: (t @ ys)) @ zs
=   { evaluation of outer @ }  
  h :: ((t @ ys) @ zs)

QED
```

## A Theorem about Folding

When we studied `List.fold_left` and `List.fold_right`, we discussed how they
sometimes compute the same function, but in general do not.  For example,

```
  List.fold_left (+) 0 [1; 2; 3]  
= (((0 + 1) + 2) + 3
= 6
= 1 + (2 + (3 + 0))
= List.fold_right (+) lst [1;2;3]
```

but

```
  List.fold_left (-) 0 [1;2;3]
= (((0 - 1) - 2) - 3
= -6
<> 2
= 1 - (2 - (3 - 0))
= List.fold_right (-) lst [1;2;3]
```

Based on the equations above, it looks like the fact that `+` is commutative and
associative, whereas `-` is not, explains this difference between when the two
fold functions get the same answer.  Let's prove it!

First, recall the definitions of the fold functions:
```
let rec fold_left f acc lst =
  match lst with
  | [] -> acc
  | h :: t -> fold_left f (f acc h) t

let rec fold_right f lst acc =
  match lst with
  | [] -> acc
  | h :: t -> f h (fold_right f t acc)
```

Second, recall what it means for a function `f : 'a -> 'a` to be commutative
and associative:
```
Commutative:  forall x y, f x y = f y x  
Associative:  forall x y z, f x (f y z) = f (f x y) z
```
Those might look a little different than the normal formulations of those
properties, because we are using `f` as a prefix operator.  If we were to write
`f` instead as an infix operator `op`, they would look more familiar:
```
Commutative:  forall x y, x op y = y op x  
Associative:  forall x y z, x op (y op z) = (x op y) op z
```
When `f` is both commutative and associative we have this little interchange
lemma that lets us swap two arguments around:
```
Lemma (interchange): f x (f y z) = f y (f x z)

Proof:

  f x (f y z)
=   { associativity }
  f (f x y) z
=   { commutativity }
  f (f y x) z
=   { associativity }
  f y (f z x) 

QED
```

Now we're ready to state and prove the theorem.
```
Theorem: If f is commutative and associative, then
  forall lst acc, 
    fold_left f acc lst = fold_right f lst acc.

Proof: by induction on lst.
P(lst) = forall acc, 
  fold_left f acc lst = fold_right f lst acc

Base case: lst = []
Show: forall acc, 
  fold_left f acc [] = fold_right f [] acc

  fold_left f acc []
=   { evaluation }
  acc
=   { evaluation }
  fold_right f [] acc

Inductive case: lst = h :: t
IH: forall acc, 
  fold_left f acc t = fold_right f t acc
Show: forall acc, 
  fold_left f acc (h :: t) = fold_right f (h :: t) acc

  fold_left f acc (h :: t)
=   { evaluation }
  fold_left f (f acc h) t
=   { IH with acc := f acc h }
  fold_right f t (f acc h)

  fold_right f (h :: t) acc
=   { evaluation }
  f h (fold_right f t acc)
```

Now, it might seem as though we are stuck: the left and right sides of the
equality we want to show have failed to "meet in the middle."  But we're
actually in a similar situation to when we proved the correctness of `facti`
earlier: there's something (applying `f` to `h` and another argument) that we
want to push into the accumulator of that last line (so that we have `f acc h`).

Let's try proving that with its own lemma:
```
Lemma: forall lst acc x, 
  f x (fold_right f lst acc) = fold_right f lst (f acc x)

Proof: by induction on lst.
P(lst) = forall acc x, 
  f x (fold_right f lst acc) = fold_right f lst (f acc x)

Base case: lst = []
Show: forall acc x, 
  f x (fold_right f [] acc) = fold_right f [] (f acc x)

  f x (fold_right f [] acc)
=   { evaluation }
  f x acc

  fold_right f [] (f acc x)
=   { evaluation }
  f acc x
=   { commutativity of f }
  f x acc

Inductive case: lst = h :: t
IH: forall acc x, 
  f x (fold_right f t acc) = fold_right f t (f acc x)
Show: forall acc x, 
  f x (fold_right f (h :: t) acc) = fold_right f (h :: t) (f acc x)

  f x (fold_right f (h :: t) acc)
=  { evaluation }
  f x (f h (fold_right f t acc))
=  { interchange lemma }
  f h (f x (fold_right f t acc))
=  { IH }
  f h (fold_right f t (f acc x))

  fold_right f (h :: t) (f acc x)
=   { evaluation }
  f h (fold_right f t (f acc x))

QED
```

Now that the lemma is completed, we can resume the proof of the theorem.
We'll restart at the beginning of the inductive case:
```
Inductive case: lst = h :: t
IH: forall acc, 
  fold_left f acc t = fold_right f t acc
Show: forall acc, 
  fold_left f acc (h :: t) = fold_right f (h :: t) acc

  fold_left f acc (h :: t)
=   { evaluation }
  fold_left f (f acc h) t
=   { IH with acc := f acc h }
  fold_right f t (f acc h)

  fold_right f (h :: t) acc
=   { evaluation }
  f h (fold_right f t acc)
=   { lemma with x := h and lst := t }
  fold_right f t (f acc h)

QED
```

It took two inductions to prove the theorem, but we succeeded!  Now we know that
the behavior we observed with `+` wasn't a fluke: any commutative and
associative operator causes `fold_left` and `fold_right` to get the same answer.

## Binary Trees

Lists and binary trees are similar when viewed as data types.  Here are the
definitions of both, side-by-side for comparison:
```
type 'a bintree =                           type 'a list =
  | Leaf                                      | []
  | Node of 'a bintree * 'a * 'a bintree      | (::) of 'a * 'a list
```
Both have a constructor that represents "empty", and both have a constructor
that combines a value of type `'a` together with another instance of the
data type.  The only real difference is that `(::)` takes just *one* list,
whereas `Node` takes *two* trees.

The induction principle for binary trees is therefore very similar to the
induction principle for lists, except that with binary trees we get
*two* inductive hypotheses, one for each subtree:
```
forall properties P,
  if P(Leaf),
  and if forall l v r, (P(l) and P(r)) implies P(Node (l, v, r)),
  then forall t, P(t)
```

An inductive proof for binary trees therefore has the following structure:
```
Proof: by induction on t.
P(t) = ...

Base case: t = Leaf
Show: P(Leaf)

Inductive case: t = Node (l, v, r)
IH1: P(l)
IH2: P(r)
Show: P(Node (l, v, r))
```

Let's try an example of this kind of proof.  Here is a function that
creates the mirror image of a tree, swapping its left and right subtrees
at all levels:
```
let rec reflect = function
  | Leaf -> Leaf
  | Node (l, v, r) -> Node (reflect r, v, reflect l)
```

For example, these two trees are reflections of each other:
```
     1               1
   /   \           /   \
  2     3         3     2
 / \   / \       / \   / \
4   5 6   7     7   6 5   4
```

If you take the mirror image of a mirror image, you should get the original
back.  That means reflection is an *involution*, which is any function `f`
such that `f (f x) = x`.  Another example of an involution is multiplication
by negative one on the integers.

Let's prove that `reflect` is an involution.

```
Claim: forall t, reflect (reflect t) = t

Proof: by induction on t.
P(t) = reflect (reflect t) = t

Base case: t = Leaf
Show: reflect (reflect Leaf) = Leaf

  reflect (reflect Leaf)
=   { evaluation }
  reflect Leaf
=   { evaluation }
  Leaf

Inductive case: t = Node (l, v, r)
IH1: reflect (reflect l) = l
IH2: reflect (reflect r) = r
Show: reflect (reflect (Node (l, v, r))) = Node (l, v, r)

  reflect (reflect (Node (l, v, r)))
=   { evaluation }
  reflect (Node (reflect r, v, reflect l))
=   { evaluation }
  Node (reflect (reflect l), v, reflect (reflect r))
=   { IH1 }
  Node (l, v, reflect (reflect r))
=   { IH2 }
  Node (l, v, r)

QED
```

Induction on trees is really no more difficult than induction on lists
or natural numbers.  Just keep track of the inductive hypotheses, using
our stylized proof notation, and it isn't hard at all.

## Induction for Any Data Type

We've now seen induction principles for `nat`, `list`, and `bintree`.
Generalizing from what we've seen, each constructor of a variant either
generates a base case for the inductive proof, or an inductive case. And, if a
constructor itself carries values of that data type, each of those values
generates in inductive hypothesis.  For example:

- `Z`, `[]`, and `Leaf` all generated base cases.

- `S`, `::`, and `Node` all generated inductive cases.

- `S` and `::` each generated one IH, because each carries one value of the
  data type.

- `Node` generated two IHs, because it carries two values of the data type.

Suppose we have these types to represent the AST for expressions in a simple
language with integers, Booleans, unary operators, and binary operators:
```
type uop =
  | UMinus

type bop =
  | BPlus
  | BMinus

type expr =
  | Int of int
  | Bool of bool
  | Unop of uop * expr
  | Binop of expr * bop * expr
```

The induction principle for `expr` is:
```
forall properties P,
  if forall i, P(Int i)
  and forall b, P(Bool b)
  and forall u e, P(e) implies P(Unop (u, e))
  and forall b e1 e2, (P(e1) and P(e2)) implies P(Binop (e1, b, e2))
  then forall e, P(e)
```
There are two base cases, corresponding to the two constructors that don't carry
an `expr`.  There are two inductive cases, corresponding to the two constructors
that do carry `expr`s.  `Unop` gets one IH, whereas `Binop` gets two IHs,
because of the number of `expr`s that each carries.

## Exercises

### Exercise 1

Prove that `forall n, mult n Z = Z` by induction on `n`, where:
```
let rec mult a b =
  match a with
  | Z -> Z
  | S k -> plus b (mult k b)
```

### Exercise 2

Prove that `forall lst, lst @ [] = lst` by induction on `lst`.

### Exercise 3

Prove that reverse distributes over append, i.e., that
`forall lst1 lst2, rev (lst1 @ lst2) = rev lst2 @ rev lst1`, where:
```
let rec rev = function
  | [] -> []
  | h :: t -> rev t @ [h]
```
(That is, of course, an inefficient implemention of `rev`.) You will need
to choose which list to induct over.  You will need the previous exercise
as a lemma, as well as the associativity of `append`, which was proved in the
notes above.

### Exercise 4

Prove that reverse is an involution, i.e., that 
  `forall lst, rev (rev lst) = lst`.
Proceed by induction on `lst`. You will the previous exercise as a lemma.

### Exercise 5

Prove that `forall t, size (reflect t) = size t` by induction on `t`, where:
```
let rec size = function
  | Leaf -> 0
  | Node (l, v, r) -> 1 + size l + size r
```

### Exercise 6

In propositional logic, we have propositions, negation, conjunction,
disjunction, and implication.  The following BNF describes propositional
logic formulas:
```
p ::= atom
    | ~ p      (* negation *)
    | p /\ p   (* conjunction *)
    | p \/ p   (* disjunction *)
    | p -> p   (* implication *)

atom ::= <identifiers>
```
For example, `raining /\ snowing /\ cold` is a proposition stating that it is
simultaneously raining and snowing and cold (a weather condition known 
as *Ithacating*).

Define an OCaml type to represent the AST of propositions.  Then state
the induction principle for that type.

## Solutions

### Exercise 1

```
Claim: forall n, mult n Z = Z
Proof: by induction on n
P(n) = mult n Z = Z

Base case: n = Z
Show: mult Z Z = Z

  mult Z Z
=   { eval mult }
  Z
  
Inductive case: n = S k
Show: mult (S k) Z = Z
IH: mult k Z = Z

  mult (S k) Z
=   { eval mult }
  plus Z (mult k Z)
=   { IH }
  plus Z Z
=   { eval plus }
  Z
  
QED
```

### Exercise 2

```
Claim:  forall lst, lst @ [] = lst
Proof: by induction on lst
P(lst) = lst @ [] = lst

Base case: lst = []
Show: [] @ [] = []

  [] @ []
=   { eval @ }
  []

Inductive case: lst = h :: t
Show: (h :: t) @ [] = h :: t
IH: t @ [] = t

  (h :: t) @ []
=   { eval @ }
  h :: (t @ [])
=   { IH }
  h :: t

QED
```

### Exercise 3

```
Claim: forall lst1 lst2, rev (lst1 @ lst2) = rev lst2 @ rev lst1
Proof: by induction on lst1
P(lst1) = forall lst2, rev (lst1 @ lst2) = rev lst2 @ rev lst1

Base case: lst1 = []
Show: forall lst2, rev ([] @ lst2) = rev lst2 @ rev []

  rev ([] @ lst2)
=   { eval @ }
  rev lst2

  rev lst2 @ rev []
=   { eval rev }
  rev lst2 @ []
=   { exercise 2 }
  rev lst2
  
Inductive case: lst1 = h :: t
Show: forall lst2, rev ((h :: t) @ lst2) = rev lst2 @ rev (h :: t)
IH: forall lst2, rev (t @ lst2) = rev lst2 @ rev t

  rev ((h :: t) @ lst2)
=   { eval @ }
  rev (h :: (t @ lst2))
=   { eval rev }
  rev (t @ lst2) @ [h]
=   { IH }
  (rev lst2 @ rev t) @ [h]
  
  rev lst2 @ rev (h :: t)
=   { eval rev }
  rev lst2 @ (rev t @ [h])
=   { associativity of @, proved in notes above }
  (rev lst2 @ rev t) @ [h]
  
QED
```

### Exercise 4

```
Claim: forall lst, rev (rev lst) = lst
Proof: by induction on lst
P(lst) = rev (rev lst) = lst

Base case: lst = []
Show: rev (rev []) = []

  rev (rev []) 
=   { eval rev, twice }
  []
  
Inductive case: lst = h :: t
Show: rev (rev (h :: t)) = h :: t
IH: rev (rev t) = t

  rev (rev (h :: t))
=   { eval rev }
  rev (rev t @ [h])
=   { exercise 3 }
  rev [h] @ rev (rev t)
=   { IH }
  rev [h] @ t
=   { eval rev }
  [h] @ t
=   { eval @ }
  h :: t
  
QED
```

## Exercise 5 

```
Claim: forall t, size (reflect t) = size t
Proof: by induction on t
P(t) = size (reflect t) = size t

Base case: t = Leaf
Show: size (reflect Leaf) = size Leaf

  size (reflect Leaf)
=   { eval reflect }
  size Leaf

Inductive case: t = Node (l, v, r)
Show: size (reflect (Node (l, v, r))) = size (Node (l, v, r))
IH1: size (reflect l) = size l
IH2: size (reflect r) = size r

  size (reflect (Node (l, v, r)))
=   { eval reflect }
  size (Node (reflect r, v, reflect l))
=   { eval size }
  1 + size (reflect r) + size (reflect l)
=   { IH1 and IH2 }
  1 + size r + size l

  size (Node (l, v, r))
=   { eval size }
  1 + size l + size r
=   { algebra }
  1 + size r + size l

QED
```

## Exercise 6

```
type prop = (* propositions *)
  | Atom of string
  | Neg of prop
  | Conj of prop * prop
  | Disj of prop * prop
  | Imp of prop * prop

Induction principle for prop:

forall properties P,
  if forall x, P(Atom x)
  and forall q, P(q) implies P(Neg q)
  and forall q r, (P(q) and P(r)) implies P(Conj (q,r))
  and forall q r, (P(q) and P(r)) implies P(Disj (q,r))
  and forall q r, (P(q) and P(r)) implies P(Imp (q,r))
  then forall q, P(q)
```


## Acknowledgements

- *The Functional Approach to Programming*, section 3.4.  Guy Cousineau and
  Michel Mauny. Cambridge, 1998.

- *ML for the Working Programmer*, second edition, chapter 6.  L.C. Paulson.
  Cambridge, 1996.

- *Thinking Functionally with Haskell*, chapter 6.  Richard Bird.  Cambridge,
  2015.

- *Software Foundations*, volume 1, chapters Basic, Induction, Lists, Poly.
  Benjamin Pierce et al. https://softwarefoundations.cis.upenn.edu/