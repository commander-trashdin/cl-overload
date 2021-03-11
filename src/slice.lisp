;;I'll try my best


(in-package :cl-overload)


(defpolymorph slice ((container array) &optional ((from ind) 0) ((to ind) (cl:length container)))
  (values vector &optional)
  (make-array (cl:- to from) :element-type (array-element-type container)
              :displaced-to container :displaced-index-offset from))



(defpolymorph-compiler-macro slice (array &optional ind ind)
  (container &optional (from 0) (to `(cl:length object)) &environment env)
  (let* ((cont-type (cm:form-type container env))
         (elt-type (cm:array-type-element-type cont-type)))
    (assert (subtypep cont-type 'sequence env))
    (once-only (from)
               `(make-array (cl:- ,to ,from) :element-type ,elt-type
                            :displaced-to ,container :displaced-index-offset ,from))))
