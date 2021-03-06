;;;; Highly experimental!


(in-package #:cl-overload)

;; At
(defpolymorph at ((array array) &rest indexes) t
  (apply #'aref array indexes))


(defpolymorph-compiler-macro at (array) (array &rest indexes &environment env)
                             (let* ((ar-type (cm:form-type array env))
                                    (ar-elt  (cm:array-type-element-type ar-type))
                                    (ar-dim  (cm:array-type-dimensions ar-type)))
                               (if (constantp (length indexes) env)
                                   (progn (when (listp ar-dim)
                                            (when (/= (length indexes) (length ar-dim))
                                              (error (format nil "Wrong number of subscripts for array of rank ~s" (length ar-dim)))))
                                          `(the (values ,ar-elt &optional) (aref ,array ,@indexes)))
                                   `(the (values ,ar-elt &optional) (apply #'aref ,array ,indexes)))))


(defpolymorph at ((list cons) &rest indexes) t
              (assert (typep (car indexes) '(mod #.array-dimension-limit)))
              (apply #'elt (the cons list) indexes))



(defpolymorph-compiler-macro at (cons) (list &rest indexes &environment env)
                               (if (constantp (length indexes) env)
                                   (progn (when (/= (length indexes) 1)
                                            (error (format nil "List access only uses 1 index")))
                                          `(elt ,list ,@indexes))
                                   `(elt ,list (car ,indexes))))






















;; Clear


(defpolymorph clear ((container vector)) vector
  (adjust-array container 0))     ;;TODO check if this can be optimized somehow



(defpolymorph clear ((container hash-table)) hash-table
  (clrhash container)
  container)
