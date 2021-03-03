(in-package #:cl-overload)

(define-polymorphic-function cast (object type))

(define-polymorphic-function deep-copy (object))



(define-polymorphic-function = (first second))
(define-polymorphic-function < (first second))
(define-polymorphic-function <= (first second))



(define-polymorphic-function at (container &rest keys))
(define-polymorphic-function (setf at) (container &rest keys))

;;TODO add math operations (+, -, *)
;;TODO add container operations:
;;emptyp
;;clear
;;size
;;subcontainer
;;merge?
;;push/pop/back/top (where it makes sense of course)
;;sort?
;;lower-bound/greater-bound

;;;; TODO from the future -- consider overhauling other standard functions that are implemented using the
;;;; above mentioned
;;;;
