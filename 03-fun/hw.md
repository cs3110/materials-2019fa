# Homework 3

1. One of the premises of functional programming is that
   mathematical functions are the basic building block of computation.
   How are OCaml functions like mathematical functions?  How are they 
   different?  As part of your answer, focus on the notion of types.
   In your opinion, is mathematics itself typed or untyped?
   (Note this is meant as a thought question, rather than a question
   with an exact right answer.)
   
2. Imagine that your boss asks you to implement a function named
   `grk` and that its type must be **exactly** `string -> bool`.  In other words,
   the toplevel would print the following when queried about the function:
```
# grk;;
grk : string -> bool = <fun>
```

   First, create such a function; it doesn't matter what the function
   actually does.
      
   Second, use the toplevel to investigate which of the following would
   be permitted by your boss's request, and which would not:
   
   * Making `grk` a recursive function.
   * Making `grk` a non-recursive function.
   * Writing a helper function and using that helper function in the body of
     `grk`.
   * Making the `string` argument a labelled argument.
      
3. Do the exercises named **fib**, **poly types**, **associativity**,
   and **print int list rec** from the current chapter of the textbook.
   
4. As a challenge, also do the **fib fast** exercise.

   
