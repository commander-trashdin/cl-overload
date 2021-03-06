(in-package #:cl-overload)

(define-polymorphic-function cast (object type))

(define-polymorphic-function deep-copy (object))
(define-polymorphic-function shallow-copy (object))


(define-polymorphic-function = (first second))
(define-polymorphic-function < (first second))
(define-polymorphic-function <= (first second))



(define-polymorphic-function at (container &rest keys))
(define-polymorphic-function (setf at) (container &rest keys))


(define-polymorphic-function emptyp (container))
(define-polymorphic-function size (container))
(define-polymorphic-function back (container))
(define-polymorphic-function front (container))
;(define-polymorphic-function (setf front) (new container))
;(define-polymorphic-function (setf back) (new container))

(define-polymorphic-function slice (container from &optional to)) ;;COW semantics


(define-polymorphic-function count (object container &key start end test))
(define-polymorphic-function find (object container &key start end test from-end))


(define-polymorphic-function lower-bound (object container &key from to test))
(define-polymorphic-function greater-bound (object container &key from to test))


(define-polymorphic-function clear (container))


;; Questionable
;;TODO add math operations (+, -, *)
;;TODO add container operations:
;;emptyp
;;clear
;;size
;;subcontainer/slice (COW)
;;merge?
;;push/pop/back/top (where it makes sense of course)
;;sort?
;;count/find/sort/lower-bound/
;;emptyp/clear/size/merge(?) or concatenate/
;;map-over(?)/do-over(????)
;;reduce as well then
;;remove/remove-if/something else

;;;; TODO from the future -- consider overhauling other standard functions that are implemented using the
;;;; above mentioned
;;;; Crazy ideas: waaay more math overhaul
;;;; Basically anything that is based on primitive ring operations can be usually extended
;;;;
;;;; Add more algorithms, and data structures (Should be a separate library)