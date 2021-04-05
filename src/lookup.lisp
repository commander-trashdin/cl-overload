;;;TODO Thinking about it I suspect that all those standard functions aren't really suited for
;;;multidim arrays anyway. Implementing them feels forced and sometimes very questionable. Decent
;;;tensor manipulation libraries will most likely have their own specific API for suc things,
;;;therefore it is probably better to not bother


(in-package :cl-overload)



;; Count. Counts how many objects are in the given (sub)container using test function
;; (default =) for comparison. For key, value containers counts keys
;; and does not allow the start/end parameters
(defpolymorph count ((object t) (container array)
                     &key ((start ind) 0)
                     ((end ind) (length container))
                     ((test function) #'=)
                     ((from-end boolean) nil)
                     ((test-not (or null function)) nil)
                     ((key function) #'identity)) ind
  ;(assert (or (and test-not (eq test #'=)) (not test-not)))
  (let ((res 0))
    (declare (type ind res))
    (if from-end
        (if test-not
            (loop :for i :from (1- end) :downto start
                  :unless (funcall (the function test-not) (funcall key (aref container i)) object)
                    :do (incf res))
            (loop :for i :from (1- end) :downto start
                  :when (funcall test (funcall key (aref container i)) object)
                    :do (incf res)))
        (if test-not
            (loop :for i :from start :below end
                  :unless (funcall (the function test-not) (funcall (aref container i)) object)
                    :do (incf res))
            (loop :for i :from start :below end
                  :when (funcall test (funcall key (aref container i)) object)
                    :do (incf res))))
    res))


(defpolymorph-compiler-macro count (t array &key (:start ind) (:end ind) (:test
                                                                             function)
                                      (:key function) (:test-not (or null function)) (:from-end boolean))
    (&whole form object container &key (start 0) (end nil) (test '#'=) (test-not nil) (key nil) (from-end nil)
            &environment env)
  (assert (or (and test-not (eq test #'=)) (not test-not)))
  (when (equalp test '#'=)
    (let* ((cont-type (cm:form-type container env))
           (elt-type (cm:array-type-element-type cont-type))
           (o-type (cm:form-type object env)))
      (unless (subtypep o-type elt-type env)
        (error 'type-error :expected-type elt-type :datum object))))
  ;;TODO check for the test/key if it can be applied, must be in separate logic
  form)




(defpolymorph count ((object t) (container list) &key ((start ind) 0)   ;;TODO this can be better
                     ((end (or null ind)) nil)
                     ((test function) #'=)
                     ((from-end boolean) nil)
                     ((test-not (or null function)) nil)
                     ((key function) #'identity)) ind
  (if (not test-not)
      (cl:count object container :start start :end end
                                 :from-end from-end :test test
                                 :key key)
      (cl:count object container :start start :end end
                                 :from-end from-end
                                 :test-not test-not :key key)))


(defpolymorph count ((object t) (container hash-table)
                     &key ((start null) nil)
                     ((end null) nil)
                     ((test function) #'=)
                     ((from-end null) nil)
                     ((test-not (or null function)) nil)
                     ((key function) #'identity)) ind
  ;(assert (or (and test-not (eq test #'=)) (not test-not)))  TODO check this with compiler macro in a sane way
  (declare (ignore start end from-end))
  (let ((res 0))
    (declare (type ind res))
    (if test-not
        (loop :for k :being :the :hash-keys :in container
              :unless (funcall (the function test-not) (funcall key k) object)
                :do (incf res))
        (loop :for k :being :the :hash-keys :in container
              :when (funcall test (funcall key k) object)
                :do (incf res)))
    res))


;; Count-if
(defpolymorph count-if ((predicate function) (container array)
                        &key ((start ind) 0)
                        ((end ind) (length container))
                        ((from-end boolean) nil)
                        ((key function) #'identity)) ind
  (let ((res 0))
    (declare (type ind res))
    (if from-end
        (loop :for i :from (1- end) :downto start
              :when (funcall predicate (funcall key (aref container i)))
                :do (incf res))
        (loop :for i :from start :below end
              :when (funcall predicate (funcall key (aref container i)))
                :do (incf res)))
    res))
