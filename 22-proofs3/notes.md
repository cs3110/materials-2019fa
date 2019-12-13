# Proofs about Programs, Part 3

Now that we are proficient at proofs about functions, we can tackle a bigger
challenge:  proving the correctness of a data structure, such as a stack,
queue, or set.

Correctness proofs always need specifications.  In proving the correctness of
iterative factorial, we used recursive factorial as a specification.  By
analogy, we could provide two implementations of a data structure---one simple,
the other complex and efficient---and prove that the two are equivalent.  
That would require us to introduce ways to translate between the two
implementations. For example, we could prove the correctness of a dictionary
implemented as a red-black tree relative to an implementation as an association
list, by defining functions to convert trees to lists.  Such an approach is
certainly valid, but it doesn't lead to new ideas about verification for us
to study.

Instead, we will pursue a different approach based on *equational
specifications*, aka *algebraic specifications*.  The idea with these is to

- define the types of the data structure operations, and 
- to write a set of equations that define how the operations interact with one
  another.

The reason the word "algebra" shows up here is (in part) that this
type-and-equation based approach is something we learned in high-school algebra.
For example, here is a specification for some operators:
```
0 : int
1 : int
- : int -> int
+ : int -> int -> int
* : int -> int -> int

(a + b) + c = a + (b + c)
a + b = b + a
a + 0 = a
a + (-a) = 0
(a * b) * c = a * (b * c)
a * b = b * a
a * 1 = a
a * 0 = 0
a * (b + c) = a * b + a * c
```
The types of those operators, and the associated equations, are facts you
learned when studying algebra.  (And if you take an *abstract algebra* course in
college, you will learn even more about them.)

Our goal is now to write similar specifications for data structures, and
use them to reason about the correctness of implementations.

## Stacks

Here are a few familiar operations on stacks along with their types.
```
module type Stack = sig
  type 'a t
  val empty : 'a t
  val is_empty : 'a t -> bool
  val peek : 'a t -> 'a
  val push : 'a -> 'a t -> 'a t
  val pop : 'a t -> 'a t
end
```
As usual, there is a design choice to be made with `peek` etc. about what to do
with empty stacks.  Here we have not used `option`, which suggests that `peek`
will raise an exception on the empty stack.  So we are cautiously relaxing
our prohibition on exceptions.

In the past we've given these operations specifications in English, e.g.,
```
  (* [push x s] is the stack [s] with [x] pushed on the top *)
  val push : 'a -> 'a stack -> 'a stack
```

But now, we'll instead write some equations to describe how the operations
work:
```
1. is_empty empty = true
2. is_empty (push x s) = false
3. peek (push x s) = x
4. pop (push x s) = s
```
(Later we'll return to the question of *how* to design such equations.)
The variables appearing in these equations are implicitly universally
quantified. Here's how to read each equation:

1. `is_empty empty = true`.  The empty stack is empty.
2. `is_empty (push x s) = false`.  A stack that has just been pushed is
   non-empty.
3. `peek (push x s) = x`.  Pushing then immediately peeking yields whatever
   value was pushed.
4. `pop (push x s) = s`.  Pushing then immediately popping yields the original
   stack.

Just with these equations alone, we already can infer a lot about how any
sequence of stack operations must work.  For example,
```
  peek (pop (push 1 (push 2 empty)))
=   { equation 4 }
  peek (push 2 empty)
=   { equation 3 }
  2
```
And `peek empty` doesn't equal any value according to the equations, since there
is no equation of the form `peek empty = ...`.  All that is true regardless of
the stack implementation that is chosen:  any correct implementation must cause
the equations to hold.

Suppose we implemented stacks as lists, as follows:
```
module ListStack = struct
  type 'a t = 'a list
  let empty = []
  let is_empty s = (s = [])
  let peek = List.hd
  let push = List.cons
  let pop = List.tl
end
```

Next we could *prove* that each equation holds of the implementation.  All these
proofs are quite easy by now, and proceed entirely by evaluation.  For example,
here's a proof of equation 3:
```
  peek (push x s)
=   { evaluation }
  peek (x :: s)
=   { evaluation }
  x
```

## Queues

Stacks were easy.  How about queues?  Here is the specification:

```
module type Queue = sig
  type 'a t
  val empty : 'a t
  val is_empty : 'a t -> bool
  val front : 'a t -> 'a
  val enq : 'a -> 'a t -> 'a t
  val deq : 'a t -> 'a t
end

1.  is_empty empty = true
2.  is_empty (enq x q) = false
3a. front (enq x q) = x            if is_empty q = true
3b. front (enq x q) = front q      if is_empty q = false
4a. deq (enq x q) = empty          if is_empty q = true
4b. deq (enq x q) = enq x (deq q)  if is_empty q = false
```

The types of the queue operations are actually identical to the types
of the stack operations.  Here they are, side-by-side for comparison:
```
module type Stack = sig            module type Queue = sig
  type 'a t                          type 'a t
  val empty : 'a t                   val empty : 'a t
  val is_empty : 'a t -> bool        val is_empty : 'a t -> bool
  val peek : 'a t -> 'a              val front : 'a t -> 'a
  val push : 'a -> 'a t -> 'a t      val enq : 'a -> 'a t -> 'a t
  val pop : 'a t -> 'a t             val deq : 'a t -> 'a t
end                                end
```
Look at each line:  though the operation may have a different name, its type
is the same.  Obviously, the types alone don't tell us enough about the
operations.  But the equations do.  Here's how to read each equation:

1. The empty queue is empty.
2. Enqueueing makes a queue non-empty.
3. Enqueueing `x` on an empty queue makes `x` the front element.
   But if the queue isn't empty, enqueueing doesn't change the front element.
4. Enqueueing then dequeueing on an empty queue leaves the queue empty.
   But if the queue isn't empty, the enqueue and dequeue operations can
   be swapped.

For example,
```
  front (deq (enq 1 (enq 2 empty)))
=   { equation 4b }
  front (enq 1 (deq (enq 2 empty)))
=   { equation 4a }
  front (enq 1 empty)
=   { equation 3a }
  1
```
And `front empty` doesn't equal any value according to the equations.

Implementing a queue as a list results in an implementation that is
easy to verify just with evaluation.
```
module ListQueue : Queue = struct
  type 'a t = 'a list
  let empty = []
  let is_empty q = q = []
  let front = List.hd
  let enq x q = q @ [x]
  let deq = List.tl
end
```

For example, 4a can be verified as follows:
```
  deq (enq x empty) 
=   { evaluation of empty and enq}
  deq ([] @ [x])
=   { evaluation of @ }
  deq [x]
=   { evaluation of deq }
  []
=   { evaluation of empty }
  empty
```

And 4b, as follows:
```
  deq (enq x q) 
=  { evaluation of enq and deq }
  List.tl (q @ [x])
=  { lemma, below, and q <> [] }
  (List.tl q) @ [x]

  enq x (deq q)
=  { evaluation }
  (List.tl q) @ [x]
```

Here is the lemma:
```
Lemma: if xs <> [], then List.tl (xs @ ys) = (List.tl xs) @ ys.
Proof: if xs <> [], then xs = h :: t for some h and t.

  List.tl ((h :: t) @ ys)
=   { evaluation of @ }
  List.tl (h :: (t @ ys))
=   { evaluation of tl }
  t @ ys

  (List.tl (h :: t)) @ ys
=   { evaluation of tl }
  t @ ys

QED
```

Note how the precondition in 3b and 4b of `q` not being empty ensures
that we never have to deal with an exception being raised in the
equational proofs.

## Two-list Queues

Here is our old friend, the two-list queue:
```
module TwoListQueue = struct
  (* AF: (f, b) represents the queue f @ (List.rev b).
     RI: given (f, b), if f is empty then b is empty. *)
  type 'a t = 'a list * 'a list

  let empty = [], []

  let is_empty (f, _) = 
    f = []

  let enq x (f, b) =
    if f = [] then [x], []
    else f, x :: b

  let front (f, _) = 
    List.hd f 

  let deq (f, b) =
    match List.tl f with
    | [] -> List.rev b, []
    | t -> t, b
end
```
This implementation is superficially different from the previous implementation
we gave, in that it uses pairs instead of records, and it in-lines the `norm`
function.  These changes will make our proofs a little easier.

Is this implementation correct?  We need only verify the equations to find out.
Here they are again, for reference.

```
1.  is_empty empty = true
2.  is_empty (enq x q) = false
3a. front (enq x q) = x            if is_empty q = true
3b. front (enq x q) = front q      if is_empty q = false
4a. deq (enq x q) = empty          if is_empty q = true
4b. deq (enq x q) = enq x (deq q)  if is_empty q = false
```

First, a lemma:
```
Lemma:  if is_empty q = true, then q = empty.
Proof:  Since is_empty q = true, it must be that q = (f, b) and f = [].
By the RI, it must also be that b = [].  Thus q = ([], []) = empty.
QED
```

Verifying 1:
```
  is_empty empty
=   { eval empty }
  is_empty ([], [])
=   { eval is_empty }
  [] = []
=   { eval = }
  true
```

Verifying 2:
```
  is_empty (enq x q) = false
=   { eval enq }
  is_empty (if f = [] then [x], [] else f, x :: b)

case analysis: f = []

  is_empty (if f = [] then [x], [] else f, x :: b)
=   { eval if, f = [] }
  is_empty ([x], [])
=   { eval is_empty }
  [x] = []
=   { eval = }
  false

case analysis: f = h :: t

  is_empty (if f = [] then [x], [] else f, x :: b)
=   { eval if, f = h :: t }
  is_empty (h :: t, x :: b)
=   { eval is_empty }
  h :: t = []
=   { eval = }
  false
```

Verifying 3a:
```
  front (enq x q) = x
=   { emptiness lemma }
  front (enq x ([], []))
=   { eval enq }
  front ([x], [])
=   { eval front }
  x
```

Verifying 3b:
```
  front (enq x q)
=   { rewrite q as (h :: t, b), because q is not empty }
  front (enq x (h :: t, b))
=   { eval enq }
  front (h :: t, x :: b)
=   { eval front }
  h

  front q
=   { rewrite q as (h :: t, b), because q is not empty }
  front (h :: t, b)
=   { eval front }
  h
```

Verifying 4a:
```
  deq (enq x q)
=   { emptiness lemma }
  deq (enq x ([], []))
=   { eval enq }
  deq ([x], [])
=   { eval deq }
  List.rev [], []
=   { eval rev }
  [], []
=   { eval empty }
  empty
```

Verifying 4b:
```
Show: deq (enq x q) = enq x (deq q)  assuming is_empty q = false.
Proof: Since is_empty q = false, q must be (h :: t, b).

Case analysis:  t = [], b = []

  deq (enq x q)
=   { rewriting q as ([h], []) }
  deq (enq x ([h], []))
=   { eval enq }
  deq ([h], [x])
=   { eval deq }
  List.rev [x], []
=   { eval rev }
  [x], []

  enq x (deq q)
=   { rewriting q as ([h], []) }
  enq x (deq ([h], []))
=   { eval deq }
  enq x (List.rev [], [])
=   { eval rev }
  enq x ([], [])
=   { eval enq }
  [x], []

Case analysis:  t = [], b = h' :: t'

  deq (enq x q) 
=   { rewriting q as ([h], h' :: t') }
  deq (enq x ([h], h' :: t'))
=   { eval enq }
  deq ([h], x :: h' :: t')
=   { eval deq }
  List.rev (x :: h' :: t'), []

  enq x (deq q)
=   { rewriting q as ([h], h' :: t') }
  enq x (deq ([h], h' :: t'))
=   { eval deq }
  enq x (List.rev (h' :: t'), [])
=   { eval enq }
  (List.rev (h' :: t'), [x])

STUCK
```

Wait, we just got stuck!  `List.rev (x :: h' :: t'), []` and 
`(List.rev (h' :: t'), [x])` are not the same.  But, abstractly, they do
represent the same queue: `(List.rev t') @ [h'; x]`.  We need to allow
an additional equation for the representation type:
```
e = e'   if  AF(e) = AF(e')
```

Using that additional equation, we can continue:
```
  (List.rev (h' :: t'), [x])
=   { AF equation }
  List.rev (x :: h' :: t'), []


The AF equation holds because:

  List.rev (h' :: t') @ [x]
=   { eval rev }
  List.rev (h' :: t') @ List.rev [x]
=   { rev distributes over @, an exercise in the previous lecture }
  List.rev ([x] @ (h' :: t'))
=   { eval @ }
  List.rev (x :: h' :: t'))
=   { lst @ [] = lst, an exercise in the previous lecture }
  List.rev (x :: h' :: t') @ []

Case analysis:  t = h' :: t'

  deq (enq x q)
=   { rewriting q as (h :: h' :: t', b) }
  deq (enq x (h :: h' :: t', b))
=   { eval enq }
  deq (h :: h' :: t, x :: b)
=   { eval deq }
  h' :: t, x :: b

  enq x (deq q)
=   { rewriting q as (h :: h' :: t', b) }
  enq x (deq (h :: h' :: t', b))
=   { eval deq }
  enq x (h' :: t', b)
=   { eval enq }
  h' :: t', x :: b

QED
```

That concludes our verification of the two-list queue.  Note that
we had to add the extra equation involving the abstraction function
to get the proofs to go through:
```
e = e'   if  AF(e) = AF(e')
```
and that we made use of the RI during the proof.  The AF and RI
really are important!

## Designing the Equations

For both stacks and queues we provided some equations as the specification.
Designing those equations is, in part, a matter of thinking hard about
the data structure.  But there's more to it than that.

Every value of the data structure is constructed with some operations. For a
stack, those operations are `empty` and `push`.  There might be some `pop`
operations involved, but those can be eliminated.  For example, `pop (push 1
(push 2 empty))` is really the same stack as `push 2 empty`. The latter is the
*canonical form* of that stack:  there are many other ways to construct it, but
that is the simplest.  Indeed, every possible stack value can be constructed
just with `empty` and `push`.  Similarly, every possible queue value can
be constructed just with `empty` and `enq`:  if there are `deq` operations
involved, those can be eliminated.

Let's categorize the operations of a data structure as follows:

- **Generators** are those operations involved in creating a canonical form.
  They return a value of the data structure type.  For example,
  `empty`, `push`, `enq`.

- **Manipulators** are operations that create a value of the data structure
  type, but are not needed to create canonical forms.  For example,
  `pop`, `deq`.

- **Queries** do not return a value of the data structure type.  For example,
  `is_empty`, `peek`, `front`.

Given such a categorization, we can design the equational specification of
a data structure by applying non-generators to generators.  For example:
What does `is_empty` return on `empty`? on `push`? What does `front` return
on `enq`? What does `deq` return on `enq`? etc.

So if there are `n` generators and `m` non-generators of a data structure, we
would begin by trying to create `n*m` equations, one for each pair of a
generator and non-generator.  Each equation would show how to simplify an
expression.  In some cases we might need a couple equations, depending on the
result of some comparison.  For example, in the queue specification, we have the
following equations:

1. `is_empty empty = true`:  this is a non-generator `is_empty` applied to a
   generator `empty`.  It reduces just to a Boolean value, which doesn't 
   involve the data structure type (queues) at all.

2. `is_empty (enq x q) = false`:  a non-generator `is_empty` applied to a
   generator `enq`.  Again it reduces simply to a Boolean value.

3. There are two subcases.
   - `front (enq x q) = x`, if `is_empty q = true`.  A non-generator `front`
     applied to a generator `enq`.  It reduces to `x`, which is a smaller
     expression than the original `front (enq x q)`.
   - `front (enq x q) = front q`, `if is_empty q = false`.  This similarly
     reduces to a smaller expression.

4. Again, there are two subcases.
   - `deq (enq x q) = empty`, if `is_empty q = true`.  This simplifies
     the original expression by reducing it to `empty`.
   - `deq (enq x q) = enq x (deq q)`, if `is_empty q = false`.  This simplifies
     the original expression by reducing it to an generator applied to a
     smaller argument, `deq q` instead of `deq (enq x q)`.

We don't usually design equations involving pairs of non-generators.  Sometimes
pairs of generators are needed, though, as we will see in the next example.

## Sets

Here is a small interface for sets:
```
module type Set = sig
  type 'a t
  val empty : 'a t
  val is_empty : 'a t -> bool
  val add : 'a -> 'a t -> 'a t
  val mem : 'a -> 'a t -> bool
  val remove : 'a -> 'a t -> 'a t
end
```

The generators are `empty` and `add`.  The only manipulator is `remove`.
Finally, `is_empty` and `mem` are queries.  So we should expect at least 2 * 3 =
6 equations, one for each pair of generator and non-generator. Here is an
equational specification:

```
1.  is_empty empty = true
2.  is_empty (add x s) = false
3.  mem x empty = false
4a. mem y (add x s) = true                    if x = y
4b. mem y (add x s) = mem y s                 if x <> y
5.  remove x empty = empty
6a. remove y (add x s) = remove y s           if x = y
6b. remove y (add x s) = add x (remove y s)   if x <> y
```

Consider, though, these two sets:
- `add 0 (add 1 empty)`
- `add 1 (add 0 empty)`

They both intuitively represent the set {0,1}.  Yet, we cannot prove
that those two sets are equal using the above specification.  We are
missing an equation involving two generators:

```
7.  add x (add y s) = add y (add x s)
```

## Exercises

### Exercise 1

A *bag* or *multiset* is like a blend of a list and a set:  like a set, order
does not matter; like a list, elements may occur more than once.  The number of
times an element occurs is its *multiplicity*.  An element that does not occur
in the bag has multiplicity 0. Here is an OCaml signature for bags:
```
module type Bag = sig
  type 'a t
  val empty : 'a t
  val is_empty : 'a t -> bool
  val insert : 'a -> 'a t -> 'a t
  val mult : 'a -> 'a t -> int
  val remove : 'a -> 'a t -> 'a t
end
```

Categorize the operations in the `Bag` interface as generators, manipulators,
or queries.  Then design an equational specification for bags.  For the `remove`
operation, your specification should cause at most one occurrence of an element
to be removed.  That is, the multiplicity of that value should decrease
by at most one.

### Exercise 2

Design an OCaml interface for lists that has `nil`, `cons`, `append`,
and `length` operations.  Design the equational specification. Hint:
the equations will look strikingly like the OCaml implementations of
`@` and `List.length`.

## Solutions

### Exercise 1

Generators: `empty`, `insert`.  Manipulator: `remove`.  Queries: `is_empty`, 
`mult`.

Specification:
```
1.  is_empty empty = true
2.  is_empty (insert x b) = false
3.  mult x empty = 0
4a. mult y (insert x b) = 1 + mult y b              if x = y
4b. mult y (insert x b) = mult y b                  if x <> y
5.  remove x empty = empty
6a. remove y (insert x b) = b                       if x = y
6b. remove y (insert x b) = insert x (remove y b)   if x <> y
7.  insert x (insert y b) = insert y (insert x b)
```

### Exercise 2

Operations:
```
module type List = sig
  type 'a t
  val nil : 'a t
  val cons : 'a -> 'a t -> 'a t
  val append : 'a t -> 'a t -> 'a t
  val length : 'a t -> int
end
```

Equations:
```
1. append nil lst = lst
2. append (cons h t) lst = cons h (append t lst)
3. length nil = 0
4. length (cons h t) = 1 + length t
```

## Acknowledgements

The example specifications above are based on McCloskey.  The terminology
of "generator", "manipulator", and "query" is based on Pfleeger and Atlee.

- "Algebraic Specifications", Robert McCloskey, 
  https://www.cs.scranton.edu/~mccloske/courses/se507/alg_specs_lec.html.

- *Software Engineering: Theory and Practice*, third edition, section 4.5.
  Shari Lawrence Pfleeger and Joanne M. Atlee.  Prentice Hall, 2006.

- "Algebraic Semantics", chapter 12 of *Formal Syntax and Semantics of
  Programming Languages*, Kenneth Slonneger and Barry L. Kurtz, Addison-Wesley,
  1995.

- "Algebraic Semantics", Muffy Thomas.  Chapter 6 in *Programming Language
  Syntax and Semantics*, David Watt, Prentice Hall, 1991.

- *Fundamentals of Algebraic Specification 1: Equations and Initial Semantics*.
  H. Ehrig and B. Mahr.  Springer-Verlag, 1985.
