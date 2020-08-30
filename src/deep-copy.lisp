(in-package #:cl-overload)


;; Deep-copy



(defstore deep-copy (object))


(defspecialization (deep-copy :inline t) ((object number)) (values number &optional)
  object)

(defspecialization (deep-copy :inline t) ((object symbol)) (values symbol &optional)
  object)

(defspecialization (deep-copy :inline t) ((object character)) (values character &optional)
  object)


(define-specialization deep-copy ((object cons)) (values cons &optional)
  (:function (lambda (obj)
               (cons (deep-copy (car obj))
                     (deep-copy (cdr obj)))))
  (:expand-function (compiler-macro-lambda (&whole form obj &environment env)
                      (if (constantp obj env)
                          `(cons (deep-copy ,(car obj))
                                 (deep-copy ,(cdr obj)))
                          form))))

(defspecialization (deep-copy :inline t) ((object string)) (values string &optional)
  (copy-seq object))

(define-specialization deep-copy ((object simple-array)) (values simple-array &optional)
  (:function (lambda (obj)
               (let ((new (make-array (array-dimensions obj))))
                 (loop :for i :from 0 :below (array-total-size obj)
                       :do (setf (row-major-aref new i)
                                 (deep-copy (row-major-aref obj i))))
                 new)))
  (:expand-function (compiler-macro-lambda (&whole form obj &environment env)
                      (cond ((constantp obj env)
                             (let ((new (make-array (array-dimensions obj) :element-type (array-element-type obj))))
                               `(loop :for i :from 0 :below (array-total-size ,obj)
                                      :do (setf (row-major-aref ,new i)
                                                (deep-copy (row-major-aref ,obj i)))
                                      :finally (return ,new))))
                            ((and (atom obj)
                                (let ((type (variable-type obj env)))
                                  (listp type))
                                (let ((type (variable-type obj env)))
                                  (= 3 (length type)))
                                (let ((type (variable-type obj env)))
                                  (every #'numberp (third type))))
                             (let* ((type (variable-type obj env))
                                    (new (make-array (third type))))
                               `(loop :for i :from 0 :below (array-total-size ,obj)
                                      :do (setf (row-major-aref ,new i)
                                                (deep-copy (row-major-aref ,obj i)))
                                      :finally (return ,new))))
                            (t form)))))


(defspecialization (deep-copy :inline t) ((object vector)) (values vector &optional)
  (let ((new (make-array (array-dimensions object)
                         :adjustable (adjustable-array-p object)
                         :fill-pointer (when (array-has-fill-pointer-p object)
                                         (fill-pointer object)))))
    (loop :for i :from 0 :below (array-total-size object)
          :do (setf (row-major-aref new i)
                    (deep-copy (row-major-aref object i))))
    new))



(defspecialization (deep-copy :inline t) ((object hash-table)) (values hash-table &optional)
  (let ((ht (make-hash-table
             :test (hash-table-test object)
             :rehash-size (hash-table-rehash-size object)
             :rehash-threshold (hash-table-rehash-threshold object)
             :size (hash-table-size object))))
    (loop :for key :being :each :hash-key :of object
            :using (hash-value value)
          :do (setf (gethash key ht) value)
          :finally (return ht))))


(defmacro define-deep-copy ((name type) &body body)
  (if (typep body
             '(cons
               (cons (eql :function) t)
               (cons (cons (eql :expand-function) t) null)))
      `(define-specialization deep-copy ((,name ,type))
           (values ,type &optional)
         ,@body)
      `(defspecialization deep-copy ((,name ,type))
           (values ,type &optional)
         ,@body)))
