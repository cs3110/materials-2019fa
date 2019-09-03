# Homework 2

*Homeworks do assume that you have read the assigned textbook
sections.  So, please make sure you have done that reading for
today before attempting the following.*

1. In your own words, explain the difference between 
   *syntax* and *semantics*.  Also explain the difference
   between *static semantics* and *dynamic semantics*.

2. The section on scope in the textbook discusses 
   this expression:
   ```
   let x = 5 in 
     ((let x = 6 in x) + x)
   ```
   Using the dynamic semanics of `let` expressions, explain
   how that expression evaluates.  
   
3. Run the following code in the toplevel.
   ```
   let x = 1;;
   let x = 2;;
   x;;
   ```
   Why is it valid to say that variables in OCaml are immutable,
   despite the output of utop?  Your answer should incorporate
   the ideas of *shadowing* and *nested let expressions.*  
   
4. Do the exercises named **operators**, **equality**, and **date fun**
   from the exercises section at the end of chapter 2 of the 3110
   textbook.
