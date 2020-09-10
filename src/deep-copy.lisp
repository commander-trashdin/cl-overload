(in-package #:cl-overload)


;; Deep-copy   --- is mediocre rn



(defspecialization (deep-copy :inline t) ((object number)) (values number &optional)
  object)

(defspecialization (deep-copy :inline t) ((object symbol)) (values symbol &optional)
  object)

(defspecialization (deep-copy :inline t) ((object character)) (values character &optional)
  object)


(defspecialization (deep-copy :inline t) ((object cons)) (values cons &optional)
  (cons (deep-copy (car object))
        (deep-copy (cdr object))))


;;; for lists?

(defspecialization (deep-copy :inline t) ((object string)) (values string &optional)
  (copy-seq object))

(defspecialization deep-copy ((object simple-array)) (values simple-array &optional)
  (let* ((l (length object))
         (new (make-array l :element-type (array-element-type object))))
    (loop :for i :from 0 :below l
          :do (setf (aref new i)
                    (deep-copy (aref object i))))
    new))



(defspecialization (deep-copy :inline t) ((object vector)) (values vector &optional)
  (let* ((l (length object))
         (new (make-array l
                          :element-type (array-element-type object)
                          :adjustable (adjustable-array-p object)
                          :fill-pointer (when (array-has-fill-pointer-p object)
                                          (fill-pointer object)))))
    (loop :for i :from 0 :below l
          :do (setf (aref new i)
                    (deep-copy (aref object i))))
    new))


(defspecialization (deep-copy :inline t) ((object array)) (values vector &optional)
  (let* ((l (array-dimensions object))
         (new (make-array l
                          :element-type (array-element-type object)
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

