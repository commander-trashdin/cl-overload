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


(defpolymorph = ((first cons) (second cons)) (values boolean &optional) ;;FIXME this needs
  (and (= (car first) (car second))                                       ;;to be inlined correctly
     (= (cdr first) (cdr second))))                                     ;;preferably not manually

#||
(defpolymorph-compiler-macro = (cons cons) (first second &environment env)
  (let* ((type1 (cm:form-type first env))
         (type2 (cm:form-type second env))
         (car1 (cm:cons-type-car-type type1))
         (car2 (cm:cons-type-car-type type2))
         (cdr1 (cm:cons-type-cdr-type type1))
         (cdr2 (cm:cons-type-cdr-type type2)))
    (once-only (first second)
      `(and (= (the ,(or (eql 'cl:* car1) car1) (car ,first)) (the ,(or (eql 'cl:* car2) car2) (car ,second)))
          (= (the ,(or (eql 'cl:* cdr1) cdr1) (cdr ,first)) (the ,(or (eql 'cl:* cdr2) cdr2) (cdr ,second)))))))
||#




;;; Autodefinition
(declaim (inline /=))
(defun /= (first second)
  (not (= first second)))
