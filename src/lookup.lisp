;;;TODO THinking about it I suspect that all those standard functions aren't really suited for
;;;multidim arrays anyway. Implementing them feels forced and sometimes very questionable. Decent
;;;tensor manipulation libraries will most likely have their own specific API for suc things,
;;;therefore it is probably better to not bother


(in-package :cl-overload)



;; Count. Counts how many objects are in the given (sub)container using test function
;; (default =) for comparison. For key, value containers counts keys
;; and does not allow the start/end parameters
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
    (object container &key (start 0) (end `(size ,container)) (test '=) &environment env)
  (let* ((cont-type (cm:form-type container env))
         (elt-type (cm:array-type-element-type cont-type)))
    `(let ((res 0))
       (declare (type ind res))
       (loop :for i :from ,start :below ,end
             :when (,test (the ,elt-type (row-major-aref ,container i)) ,object)
               :do (incf res))
       res)))

(defpolymorph count ((object t) (container list)
                                &key ((start ind) 0)
                                ((end ind) (size container))
                                ((test function) #'=)) ind
 (cl:count object container :start start :end end :test test))




;; Position. Returns index(es) of the object in the container. If not found, returns nil
(defpolymorph position ((object t) (container array)
                        &key ((start ind) 0)
                        ((end ind) (size container))
                        ((test function) #'=)
                        ((from-end boolean) nil)) (or ind null)
  (if from-end
      (loop :until (= end start)
            :do (decf end)
            :when (funcall test (row-major-aref container end) object)
              :do (return-from position end))
      (loop :until (= end start)
            :when (funcall test (row-major-aref container start) object)
              :do (return-from position start)
            :do (incf start))))



(defpolymorph-compiler-macro position (t array &key (:start ind) (:end ind)
                                         (:test function) (:from-end boolean))
    (object container &key (start 0) (end `(size ,container)) (test '=) (from-end nil) &environment env)
  (let* ((cont-type (cm:form-type container env))
         (elt-type (cm:array-type-element-type cont-type))
         (pos (gensym "POS")))
    `(if ,from-end
         (let ((,pos ,end))
           (declare (type ind ,pos))
           (loop :until (= ,pos ,start)
                 :do (decf ,pos)
                 :when (,test (the ,elt-type (row-major-aref ,container ,pos)) ,object)
                   :do (return ,pos)))
         (let ((,pos ,start))
           (declare (type ind ,pos))
           (loop :until (= ,pos ,end)
                 :when (,test (the ,elt-type (row-major-aref ,container ,pos)) ,object)
                   :do (return ,pos)
                 :do (incf ,pos))))))


(defpolymorph find ((object t) (container array)
                    &key ((start ind) 0)
                    ((end ind) (size container))
                    ((test function) #'=)
                    ((from-end boolean) nil)) (or t null)
  (if from-end
      (loop :until (= end start)
            :do (decf end)
            :when (funcall test (row-major-aref container end) object)
              :do (return-from find (row-major-aref container end)))
      (loop :until (= end start)
            :when (funcall test (row-major-aref container start) object)
              :do (return-from find (row-major-aref container start))
            :do (incf start))))



(defpolymorph-compiler-macro find (t array &key (:start ind) (:end ind)
                                     (:test function) (:from-end boolean))
    (object container &key (start 0) (end `(size ,container)) (test '=) (from-end nil) &environment env)
  (let* ((cont-type (cm:form-type container env))
         (elt-type (cm:array-type-element-type cont-type))
         (pos (gensym "POS")))
    ;(when (and (listp container) (eql 'reverse (first container))) ;; This is wrong anyway, should be about function, not name
    ;  (setf from-end `(not ,from-end)                              ;; Also, we are not SERIES
    ;        container (second container)))
    (once-only (container)
      `(if ,from-end
           (let ((,pos ,end))
             (declare (type ind ,pos))
             (loop :until (= ,pos ,start)
                   :do (decf ,pos)
                   :when (,test (the ,elt-type (row-major-aref ,container ,pos)) ,object)
                     :do (return (the ,elt-type (row-major-aref ,container ,pos)))))
           (let ((,pos ,start))
             (declare (type ind ,pos))
             (loop :until (= ,pos ,end)
                   :when (,test (the ,elt-type (row-major-aref ,container ,pos)) ,object)
                     :do (return (the ,elt-type (row-major-aref ,container ,pos)))
                   :do (incf ,pos)))))))
