;;;; Highly experimental!


(in-package #:cl-overload)

;; At
(defpolymorph at ((array array) &rest indexes) t
  (apply #'aref array indexes))

(defpolymorph-compiler-macro at (array &rest) (array &rest indexes &environment env)
  (let* ((ar-type (cm:form-type array env))
         (elt-type  (cm:array-type-element-type ar-type)))
    (if (constantp (length indexes) env)
        `(the (values ,elt-type &optional) (aref ,array ,@indexes))
        `(the (values ,elt-type &optional) (apply #'aref ,array ,indexes)))))


(defpolymorph (setf at) ((new t) (array array) &rest indexes) t
  (setf (apply #'aref array indexes) new))



(defpolymorph-compiler-macro (setf at) (t array &rest) (new array &rest indexes &environment env)
  (let* ((ar-type (cm:form-type array env))
         (elt-type  (cm:array-type-element-type ar-type))
         (new-type (cm:form-type new env)))
    (cond ((not (subtypep new-type elt-type env))
           (error 'type-error :expected-type elt-type :datum new))
          ((constantp (length indexes) env)
           `(the (values ,elt-type &optional) (setf (aref ,array ,@indexes)
                                                    (the (values ,elt-type &optional) ,new))))
          (t
           `(the (values ,elt-type &optional) (setf (apply #'aref ,array ,indexes)
                                                    (the (values ,elt-type &optional) ,new)))))))












(defpolymorph at ((list list) &rest indexes) t
  (apply #'elt (the cons list) indexes))



(defpolymorph-compiler-macro at (list &rest) (list &rest indexes &environment env)
  (if (constantp (length indexes) env)
      `(elt ,list ,@indexes)
      `(apply #'elt ,list ,indexes)))



(defpolymorph (setf at) ((new t) (list list) &rest indexes) t
  (setf (apply #'elt list indexes) new))



(defpolymorph-compiler-macro (setf at) (t list &rest) (new list &rest indexes &environment env)
  (if (constantp (length indexes) env)
      `(setf (elt ,list ,@indexes) ,new)
      `(setf (apply #'elt ,list ,indexes) new)))





(defpolymorph at ((ht hash-table) &rest indexes) (values t boolean &optional)
  (apply #'gethash (first indexes) ht (cdr indexes)))



(defpolymorph-compiler-macro at (hash-table &rest) (ht &rest indexes &environment env)
  (let ((ht-type (print (cm:form-type ht env))))
   (if (constantp (length indexes) env)
       (if (listp ht-type)      ;; TODO this trick doesn't work unfortunately, but it might.
           (let ((key-type (second ht-type))
                 (val-type (third ht-type))
                 (attempt-type (cm:form-type (car indexes) env)))
             (if (subtypep attempt-type key-type env)
                 `(the (values ,val-type boolean &optional)
                       (gethash ,(first indexes) ,ht ,(second indexes)))
                 (error 'type-error :expected-type key-type :datum (car indexes))))
          `(gethash ,(first indexes) ,ht ,(second indexes)))
       (once-only (indexes)
         `(apply #'gethash (first ,indexes) ,ht (cdr ,indexes))))))



;; TODO (setf at) for hash-tables












;; Clear


(defpolymorph clear ((container vector)) vector
  (adjust-array container 0 :fill-pointer t))


(defpolymorph clear ((container hash-table)) hash-table
  (clrhash container)
  container)
