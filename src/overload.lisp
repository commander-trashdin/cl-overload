(in-package #:cl-overload)

(define-polymorphic-function cast (object type):overwrite t
  :documentation "Cast an object to a specified type. Type should always be a symbol.
  Non-mutating, i.e. always return a new object.")

(define-polymorphic-function deep-copy (object) :overwrite t
  :documentation "Deep-copy copies object recursively.
  Return object has the same type as the original one.")
(define-polymorphic-function shallow-copy (object) :overwrite t
  :documentation "Copy the topmost container, leaving insides as references.
  Return object has precisely the same type as the original one.")


(define-polymorphic-function = (first second) :overwrite t
  :documentation "Return T if all of its arguments are , NIL otherwise.")
(define-polymorphic-function < (first second) :overwrite t
  :documentation "Return T if its arguments are in strictly increasing order, NIL otherwise.")
(define-polymorphic-function <= (first second) :overwrite t
  :documentation "Return T if arguments are in strictly non-decreasing order, NIL otherwise.")



(define-polymorphic-function at (container &rest keys) :overwrite t
  :documentation "If used with array/list return the element of the container specified by the keys.
  If used with a map, find the entry in it with (funcall test key KEY) => T and return the
  associated value and T as multiple values, or return DEFAULT and NIL if there is no such entry.")
(define-polymorphic-function (setf at) (new container &rest keys) :overwrite t
  :documentation "Setf for at. Use return value of at if needed.")


(define-polymorphic-function emptyp (container) :overwrite t
  :documentation "Return T if container is empty, and NIL otherwise.")
(define-polymorphic-function size (continer) :overwrite t
  :documentation "Return the size of stored data inside the container.")
(define-polymorphic-function capacity (container) :overwrite t
  :documentation "Return the upper limit of what can be currently
  stored in the container.")
(define-polymorphic-function back (container) :overwrite t
  :documentation "Return last element of the container.")
(define-polymorphic-function front (container) :overwrite t
  :documentation "Return first of the container.")
(define-polymorphic-function (setf front) (new container) :overwrite t
  :documentation "Setf for front. Use return value of front if needed.")
(define-polymorphic-function (setf back) (new container) :overwrite t
  :documentation "Setf for back. Use return value of back if needed.")

(define-polymorphic-function slice (container &optional from to) :overwrite t
  :documentation "Return an object that represents a view on some part of the container.
  Use COW semantics, i.e. copy the stored elements on an attempt to mutate the slice.")


(define-polymorphic-function map (res-type function container &rest containers) :overwrite t
  :documentation "Applies function to successive sets of arguments in which one argument is obtained
 from each container. The function is called on all elements of given containers in successive order.
 The result-type specifies the type of the resulting container. Return nil if result-type is nil.
 The resulting container is as big as the smallest of the containers. ")
(define-polymorphic-function reduce (function container &key key from-end start end initial-value) :overwrite t
  :documentation "Use a binary operation, function, to combine the elements of container
 bounded by start and end (when it makes sense).")


(define-polymorphic-function count (object container &key start end test from-end key test-not) :overwrite t
  :documentation "Count and return the number of elements in the container bounded by start and end that satisfy the test with object.")
(define-polymorphic-function count-if (predicate container &key start end from-end key) :overwrite t
  :documentation "Count and return the number of elements in the container bounded by start and end that satisfy the predicate.")
(define-polymorphic-function find (object container &key start end test from-end key test-not) :overwrite t
  :documentation "Search for an element of the container bounded by start and end that satisfies the test with object.")
(define-polymorphic-function find-if (predicate container &key start end from-end key) :overwrite t
  :documentation "Searches for an element of the container bounded by start and end that satisfies the predicate.")
(define-polymorphic-function position (object container &key start end test from-end key test-not) :overwrite t
  :documentation "Search the container for an element that satisfies the test with the object. Return the index/key within container of
  the leftmost (if from-end is true) or of the rightmost (if from-end is false) element that satisfies the test; otherwise
  return nil.")
(define-polymorphic-function position-if (predicate container &key start end from-end key) :overwrite t
  :documentation "Search the container for an element that satisfies the predicate. Return the index/key within container of
  the leftmost (if from-end is true) or of the rightmost (if from-end is false) element that satisfies the predicate; otherwise
  return nil.")




(define-polymorphic-function lower-bound (object container &key start end test) :overwrite t
  :documentation "Return an index/key of the first element of the container in the range from start to end that is not less than
  (i.e. greater or equal to) object, or size of the container if no such element is found.")
(define-polymorphic-function upper-bound (object container &key start end test) :overwrite t
  :documentation "Return an index/key of the first element of the container in the range from start to end that is greater than
  object, or size of the container if no such element is found.")


(define-polymorphic-function clear (container) :overwrite t
  :documentation "Erase all elements from the container. After this call, size should return 0.")


(define-polymorphic-function fill (container item &key start end copy) :overwrite t
  :documentation "Replace the elements of container bounded by start and end with item.")
(define-polymorphic-function replace (target source &key start1 end1 start2 end2 copy) :overwrite t
  :documentation "Destructively modify target by replacing the elements of slice-1 bounded by start1 and end1 with the elements of slice-2 bounded by start2 and end2.")
(define-polymorphic-function substitute (new old container &key from-end test
                                             start end count mut)
  :overwrite t
  :documentation "Calls foo polymorphs")
(define-polymorphic-function substitute-if (new predicate container
                                                &key from-end start end count mut)
  :overwrite t
  :documentation "Calls foo polymorphs")
(define-polymorphic-function remove (object container &key from-end
                                            test test-not start
                                            end count key)
  :overwrite t
  :documentation "Return a copy of container with elements satisfying the test (default is
  =) with object removed.")
(define-polymorphic-function remove-if (predicate container &key from-end start
                                                  end count key)
  :overwrite t
  :documentation "Calls foo polymorphs")



;;;; TODO from the future -- consider overhauling other standard functions that are implemented using the
;;;; above mentioned

;;;; Add more algorithms, and data structures (Should be a separate library)
