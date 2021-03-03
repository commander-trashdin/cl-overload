(in-package #:cl-overload)


;; Equality


(defpolymorph =  ((first number) (second number)) (values boolean &optional)
              (cl:= first second))

(defpolymorph = ((first symbol) (second symbol)) (values boolean &optional)
              (eql first second))

(defpolymorph = ((first character) (second character)) (values boolean &optional)
              (char= first second))

(defpolymorph = ((first string) (second string)) (values boolean &optional)
              (string= first second))


(defpolymorph = ((first cons) (second cons)) (values boolean &optional)
              (and (= (car first) (car second))
                 (= (cdr first) (cdr second))))



;;; Autodefinition
(declaim (inline /=))
(defun /= (first second)
  (not (= first second)))
