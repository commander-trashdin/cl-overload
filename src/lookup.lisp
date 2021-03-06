


(in-package :cl-overload)


#||
(defpolymorph count ((object t) (container array)
                                &key ((start ind) 0)
                                ((end ind) (size container))
                                ((test function) #'=)) ind
  (let ((res 0))
    (declare (type ind res))
    (loop :for i :from start :below end
          :when (funcall test (row-major-aref container i) object)
            :do (incf res))
    res))

(defpolymorph-compiler-macro count (t array &key (:start ind) (:end ind) (:test function))
    (object container &key (start 0) (end (size container)) (test #'=) &environment env)
  (let* ((cont-type (cm:form-type container env))
         (cont-elt  (cm:array-type-element-type cont-type))
         (cont-dim  (cm:array-type-dimensions cont-type))
         (o-type (cm:form-type object env)))
                                        ;(s-type (cm:form-type start env))
                                        ;(e-type (cm:form-type ind env))
                                        ;(test-type (cm:form-type test env)))
    (print cont-type)
    (print cont-elt)
    (cond ((not (subtypep o-type cont-elt env))
           `(progn (error 'type-error :expected-type ,cont-elt)
                   0))
          ((or (subtypep cont-type 'vector env) (and (listp cont-dim) (= 1 (length cont-dim))))
           `(let ((res 0))
              (declare (type ind res))
              (loop :for i :from ,start :below ,end
                    :when (,test (aref ,container i) ,object)
                      :do (incf res))
              res))
          (t
           `(let ((res 0))
              (declare (type ind res))
              (loop :for i :from ,start :below ,end
                    :when (,test (row-major-aref ,container i) ,object)
                      :do (incf res))
              res)))))
||#


(define-polymorphic-function %count (object array))

(defpolymorph %count ((object t) (container array)) ind
  (let ((res 0))
    (declare (type ind res))
    (loop :for i :from 0 :below (size container)
          :when (= (row-major-aref container i) object)
            :do (incf res))
    res))


(defpolymorph-compiler-macro %count (t array)
    (object container &environment env)
  (let* ((cont-type (cm:form-type container env))
         (cont-elt  (cm:array-type-element-type cont-type))
         (o-type (cm:form-type object env)))
    (print cont-type)
    (print o-type)
    (if (not (subtypep o-type cont-elt env))
        (error 'type-error :expected-type cont-elt :datum object)
        `(let ((res 0))
           (declare (type ind res))
           (loop :for i :from 0 :below (size ,container)
                 :when (= (row-major-aref ,container i) ,object)
                   :do (incf res))
           res))))
