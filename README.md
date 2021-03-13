# CL Overload

Inspired by [generic-cl](https://github.com/alex-gutev/generic-cl) and  [specialization-store](https://github.com/markcox80/specialization-store), this library provides support for overloading common simple functions (in many other languages usually references as "operators") based on types. Supports user defined specializations as well. It also tries to be as strictly typed as possible, resulting in compile-time errors/warnings in case types are mismatched. However, there are ways to relax the restrictions in places where it would make sense (such as different numeric types comparison).


## Implementations support
It currently works properly (i.e without overhead) anywhere, where [adhoc polymorphic functions](https://github.com/digikar99/adhoc-polymorphic-functions) work. Cltl2 support is the most important thing.


# Manual

(Note: not everything here is implemented yet, so this is also a roadmap)

## Functions
- Cast
``` common-lisp
(define-polymorphic-function cast (object type))
```
Casts an object to a specified type. Type should always be a symbol. Non-mutating, i.e. always returns a new object.

- Copy
``` common-lisp
(define-polymorphic-function deep-copy (object))
(define-polymorphic-function shallow-copy (object))
```
Deep-copy copies object recursively, while shallow-copy only copies the topmost container, leaving insides as references. Returns object of precisely the same type as the original one.

- (In)equality
``` common-lisp
(define-polymorphic-function = (first second))
(define-polymorphic-function < (first second))
(define-polymorphic-function <= (first second))
```
Standart mathematical comparison. By default is defined by reals, chars and strings. Should alwasy return boolean.

- At
``` common-lisp
(define-polymorphic-function at (container &rest keys))
(define-polymorphic-function (setf at) (new container &rest keys))
```
Accessor to the containers, similar to `[]` in C-like languages. Works for arbitrary kyes as well as multiple indexes. Is SETFable.

- Emptyp
``` common-lisp
(define-polymorphic-function emptyp (container))
```
Checks is a container is empty for a user point of view. Returns boolean.

- Size

``` common-lisp
(define-polymorphic-function size (container))
(define-polymorphic-function capacity (container))
```
Size returns the size of stored data inside the container. Capacity returns the upper limit of what can be currently stored in the container.


- Front/Back

``` common-lisp
(define-polymorphic-function back (container))
(define-polymorphic-function front (container))
(define-polymorphic-function (setf front) (new container))
(define-polymorphic-function (setf back) (new container))
```
Front and back return first and last elements of the container respectively. Both are SETFable.


- Slice

``` common-lisp
(define-polymorphic-function slice (container &optional from to)) ;;COW semantics
```
Slice returns an object that represents a view on some part of the container. It uses COW semantics, i.e. copies the stored elements on an attempt to mutate the slice.

- Count

``` common-lisp
(define-polymorphic-function count (object container &key start end test))
```
Count and return the number of elements in the container bounded by start and end that satisfy the test.


- Find

``` common-lisp
(define-polymorphic-function find (object container &key start end test from-end))
```
Searches for an element of the container bounded by start and end that satisfies the test.


- Position

``` common-lisp
(define-polymorphic-function position (object container &key start end test from-end))
```
Searches the container for an element that satisfies the test.
The position returned is the index/key within container of the leftmost (if from-end is true) or of the rightmost (if from-end is false) element that satisfies the test; otherwise `nil` is returned.


- Binary search
``` common-lisp
(define-polymorphic-function lower-bound (object container &key start end test))
(define-polymorphic-function upper-bound (object container &key start end test))
```
Lower-bound returns an index of the first element of the container in the range from start to end that is not less than (i.e. greater or equal to) object, or size of the container if no such element is found.

Upper-bound returns an index of the first element of the container in the range from start to end that is greater than object, or size of the container if no such element is found.

Both use the given test for comparison, which is  `#'<` by default.

- Clear

``` common-lisp
(define-polymorphic-function clear (container))
```
Erases all elements from the container. After this call, size returns 0.
Leaves the capacity of the vector unchanged.


- Fill

``` common-lisp
(define-polymorphic-function fill (container item &key start end copy))
```

- Replace

``` common-lisp
(define-polymorphic-function replace (target source &key start1 end1 start2 end2 copy))
```

- Substitute

``` common-lisp
(define-polymorphic-function substitute (new old container &key from-end test
                                             start end count mut))
(define-polymorphic-function substitute-if (new predicate container
                                                &key from-end start end count mut))
```




## Macros and Utility

- Default
Returns a reasonable default object for a given type.

- Bind
Unites 3 things: `let*`, `multiple-value-bind` and builtin type declarations. Uses default for filling out the values if types was provided, otherwise defaults to `nil`.

Examples of usage:

``` common-lisp
(tbind* ((x :t fixnum 10)   ; x is 10
         (y :t string)      ; y is an empty vector of characters
         (z (random 42))    ; z is exactly what it is supposed to be
         ((a b) :t (fixnum fixnum) (floor 179 57)))  ; a and b are 3 and 8 respectively
  body)
```

- Deftuple

A simplification of `defstruct` that fills in default values using `default` and given types and has accessors for slots defined via defpolymorph. Is able to do simple inheritance. Very much alpha version.

Example:
``` common-lisp
(deftuple point (foo)
   (float Ox 1.0)
   (float Oy))))
```


Note: 

Maybe it would have been better with MOP. But I am not good at MOP and also this is more of an example of what kind of interface could be implemented. I would consider suggestions on how to improve this.
The goal is not to implement some kind of new object system, but rather provide a convenient
interface for an existing one, if neccesary.
