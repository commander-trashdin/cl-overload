(in-package #:cl-overload)


;; Equality


(defpolymorph = ((first number) (second number)) (values boolean &optional)
  (cl:= first second))

#||
(defpolymorph-compiler-macro = (number number) (first second &environment env)
  (let ((first-type (cm:form-type first env))
        (second-type (cm:form-type second env)))
    (print first-type)
    (print second-type)
    (print
     (if (and (listp first-type) (listp second-type)
            (equalp first-type second-type))
         t
         `(cl:= ,first ,second)))))
||#

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
