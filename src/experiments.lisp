

(in-package :cl-overload)

;;;; Experimental


;;; Usage
;;; (vec 'fixnum) => (make-array 0 :el-type 'fixnum :init default :adjustable t :fill-pointer 0)
;;; (vec 'fixnum 10) => (make-array 10 :el-type 'fixnum :init default :adjustable t :fill-pointer 0)
;;; (vec 'fixnum '(1 2 3)) <- this is a problem
;;; (vec 'fixnum 20 3) => (make-array 20 :el-type 'fixnum :init 3 :adjustable t :fill-pointer 0)
;;; (vec) => (make-array 0 :el-type t :init default :adjustable t :fill-pointer 0)
;;; (vec '(1 2 3 4 5)) => (make-array 5 :el-type ?? (fixnum? t?) :adjustable t :fill-pointer 5 :initial-contents (that list))
;;; (vec 'fixnum 40 '(1 2 3 4 5)) => (make-array 40 :el-type 'fixnum :adjustable t :fill-pointer 5 :initial-contents (that list))
;;; I consider all the above useful, and I cannot (as of rn) come up with anything else useful

(defmacro vec (&rest args &environment env)
  (case (length args)
    (0 `(make-array 0 :adjustable t :fill-pointer 0))
    (1 (etypecase (car args)
         (symbol `(make-array 0 :element-type ,(car args)
                                :initial-element ,(default (car args) env)
                                :adjustable t :fill-pointer 0))
         (list (if (some #'symbolp (car args))
                   `(make-array 0 :element-type ,(car args)
                                  :initial-element ,(default (car args) env)
                                  :adjustable t :fill-pointer 0)
                   (let* ((name (gensym "VEC"))
                          (init (car args))
                          (l (length init)))
                     `(let ((,name (make-array ,l :adjustable t :fill-pointer 0)))
                        ,@(loop :for i :from 0 :below l
                                :collect `(setf (aref ,name ,i) ,(elt init i)))
                        ,name))))))
    (2 t))) ;;TODO
