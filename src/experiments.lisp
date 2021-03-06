

(in-package :cl-overload)

;;;; Experimental

(define-polymorphic-function make (typename &rest args))


(defpolymorph make ((typename list) &rest args) t
  (apply #'make (first typename) (second typename) args))

(defpolymorph-compiler-macro make (list) (typename &rest args &environment env)
  (let* ((container-type (first (eval typename)))
         (element-type (second (eval typename))))
    (print `(make ',container-type ',element-type ,@args))))


(defpolymorph make ((typename (member vector)) &rest args) vector
  (declare (ignore typename))
  (make-array (second args) :element-type (first args) :adjustable t :fill-pointer 0))

(defpolymorph-compiler-macro make ((member vector)) (typename &rest args &environment env)
                             (let* ((elt-type (eval (first args)))
                                    (size (second args)))
                               (print
                                `(the (vector ,elt-type)
                                      (make-array ,size :element-type ',elt-type :adjustable t :fill-pointer 0)))))
