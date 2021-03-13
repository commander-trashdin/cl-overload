# CL Overload

Inspired by [generic-cl](https://github.com/alex-gutev/generic-cl) and  [specialization-store](https://github.com/markcox80/specialization-store), this library provides support for overloading common simple functions (in many other languages usually references as "operators") based on types. Supports user defined specializations as well. It also tries to be as strictly typed as possible, resulting in compile-time errors/warnings in case types are mismatched. However, there are ways to relax the restrictions in places where it would make sense (such as different numeric types comparison).


# Implementations support
It currently works properly (i.e without overhead) anywhere, where [adhoc polymorphic functions](https://github.com/digikar99/adhoc-polymorphic-functions) work. Cltl2 support is the most important thing.


# Manual

(Note: not everything here is implemented yet, so this is also a roadmap)

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


(define-polymorphic-function emptyp (container))
(define-polymorphic-function size (container))
(define-polymorphic-function capacity (container))
(define-polymorphic-function back (container))
(define-polymorphic-function front (container))
(define-polymorphic-function (setf front) (new container))
(define-polymorphic-function (setf back) (new container))

(define-polymorphic-function slice (container &optional from to)) ;;COW semantics


(define-polymorphic-function count (object container &key start end test))
(define-polymorphic-function find (object container &key start end test from-end))
(define-polymorphic-function position (object container &key start end test from-end))

(define-polymorphic-function lower-bound (object container &key start end test))
(define-polymorphic-function greater-bound (object container &key start end test))


(define-polymorphic-function clear (container))


(define-polymorphic-function fill (container item &key start end copy))
(define-polymorphic-function replace (target source &key start1 end1 start2 end2 copy))
(define-polymorphic-function substitute (new old container &key from-end test
                                             start end count mut))
(define-polymorphic-function substitute-if (new predicate container
                                                &key from-end start end count mut))
