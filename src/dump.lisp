



(defpolymorph-compiler-macro count (t array &key (:start ind) (:end ind) (:test function)
                                      (:key function) (:key test-not))
  (object container &key (start 0) (end `(size ,container)) (test '=) (test-not nil)
          (key 'identity) &environment env)
  (let* ((cont-type (cm:form-type container env))
         (elt-type (cm:array-type-element-type cont-type)))
    (if (constantp container env)
        `(the ind (cl:count ,object ,container :start ,start :end ,end
                            :test ,(if (eql test '=) #'= test)))

        `(let ((res 0))
           (declare (type ind res))
           (loop :for i :from ,start :below ,end
                 :when (,test (the ,elt-type (row-major-aref ,container i)) ,object)
                 :do (incf res))
           res))))

(defpolymorph count ((object t) (container list)
                     &key ((start ind) 0)
                     ((end ind) (size container))
                     ((test function) #'=)
                     ((test-not function) #'=)
                     ((key function) #'identity)) ind
  (if test
      (cl:count object container :start start :end end :test test :key identity)
      (cl:count object container :start start :end end :test-not test-not :key identity)))



;; Position. Returns index(es) of the object in the container. If not found, returns nil
(defpolymorph position ((object t) (container array)
                        &key ((start ind) 0)
                        ((end ind) (size container))
                        ((test function) #'=)
                        (((test function) #'=))
                        ((key function) #'identity)
                        ((from-end boolean) nil)) (or ind null)
  (if from-end
      (loop :until (= end start)
            :do (decf end)
            :when (funcall test (funcall key (row-major-aref container end)) object)
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
    (if (constantp container env)
        `(the ind (cl:position ,object ,container :start ,start :end ,end :from-end ,from-end
                                                  :test ,(if (eql test '=) #'= test)))
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
                     :do (incf ,pos)))))))

(defpolymorph find ((object t) (container array)
                    &key ((start ind) 0)
                    ((end ind) (size container))
                    ((test function) #'=)
                    ((test-not function) #'=)
                    ((key function) #'identity)
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
    (if (constantp container env)
        `(the ind (cl:find ,object ,container :start ,start :end ,end :from-end ,from-end
                                              :test ,(if (eql test '=) #'= test)))
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
                       :do (incf ,pos))))))))















;; Just to have some sane code for lower-bound
(defpolymorph lower-bound ((object t) (container array)
                           &key ((start ind) 0)
                           ((end ind) (size container))
                           ((test function) #'<))
  (or t null)
  (let ((first start)
        (count (cl:- end start)))
    (declare (type ind count))
    (loop :while (< 0 count)
          :for it :of-type ind := first
          :for step :of-type ind := (floor count 2)
          :do (incf it step)
          (if (funcall test (aref container it) object)
              (progn (setf first (incf it))
                     (decf count (cl:+ step 1)))
              (setf count step)))
    first))
