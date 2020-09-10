(in-package #:cl-overload)


;; Equality


(defspecialization (= :inline t) ((first number) (second number)) (values boolean &optional)
  (cl:= first second))

(defspecialization (= :inline t) ((first symbol) (second symbol)) (values boolean &optional)
  (eql first second))

(defspecialization (= :inline t) ((first character) (second character)) (values boolean &optional)
  (char= first second))

(defspecialization (= :inline t) ((first string) (second string)) (values boolean &optional)
  (string= first second))

#||
(define-specialization = ((first cons) (second cons)) (values boolean &optional)
  (:function (lambda (first second)
               (and (= (car first) (car second))
                  (= (cdr first) (cdr second)))))
  (:expand-function (compiler-macro-lambda (&whole form first second &environment env)
                      (if (and (constantp first env) (constantp second env))
                          (and (= (car first) (car second))
                             (= (cdr first) (cdr second)))
                          form))))
||#

(defspecialization (= :inline t) ((first cons) (second cons)) (values boolean &optional)
  (and (= (car first) (car second))
     (= (cdr first) (cdr second))))

(defspecialization (= :inline t) ((first list) (second list)) (values boolean &optional)  ;; TODO does it work?
  (loop :for fobj :in first
        :for sobj :in second
        :always (= fobj sobj)))


(defspecialization (= :inline t) ((first vector) (second vector)) (values boolean &optional)
   (and (cl:= (length first) (length second))
      (loop :for ind :from 0 :below (length second)
            :always (= (aref first ind)
                       (aref second ind)))))

(defspecialization (= :inline t) ((first simple-array) (second simple-array)) (values boolean &optional)
   (and (cl:= (length first) (length second))
      (loop :for ind :from 0 :below (length second)
            :always (= (row-major-aref first ind)
                       (row-major-aref second ind)))))

(defspecialization (= :inline t) ((first array) (second array)) (values boolean &optional)
   (and (= (array-dimensions first) (array-dimensions second))
      (loop :for ind :from 0 :below (array-total-size second)
            :always (= (row-major-aref first ind)
                       (row-major-aref second ind)))))



(defspecialization (= :inline t) ((first hash-table) (second hash-table)) (values boolean &optional)
  (loop :for k1 :being :each :hash-key :of first
          :using (hash-value v1)
        :do (multiple-value-bind (v2 exists) (gethash k1 second)
              (unless (and exists (= v1 v2))
                (return nil)))
        :finally (return t)))



;;; Autodefinition
(declaim (inline /=))
(defun /= (first second)
  (not (= first second)))
