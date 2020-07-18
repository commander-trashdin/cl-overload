;;;; cl-overload.lisp

(in-package #:cl-overload)





(defparameter *comparable* '((number number)))


(defun %comparable-types-p (type1 type2)
  (or (eql type1 type2)
     (loop :for (comp1 comp2) :in *comparable*
           :thereis (or (and (subtypep type1 comp1)
                          (subtypep type2 comp2))
                       (and (subtypep type1 comp2)
                          (subtypep type2 comp1))))))


(defun == (first second &rest objects)
  (every (lambda (b) (%== first b)) (cons second objects)))

(defun =/= (first second &rest objects)
  (some (lambda (b) (not (%== first b))) (cons second objects)))

(define-compiler-macro == (&whole form first second &rest objects &environment env)
  (if (constantp (length objects) env)
      (case (length objects)
        (0 `(not (%== ,first ,second)))
        (otherwise `(or ,@(mapcar (lambda (a) `(not (%== ,first ,a))) (cons second objects)))))
      form))


(define-compiler-macro =/= (&whole form first second &rest objects &environment env)
  (if (constantp (length objects) env)
      (case (length objects)
        (0 `(not (%== ,first ,second)))
        (otherwise `(and ,@(mapcar (lambda (a) `(%== ,first ,a)) (cons second objects)))))
      form))

(declaim (inline %==))
(defun %== (fobj sobj)
  (%%== fobj sobj))

(define-compiler-macro %== (&whole form fobj sobj &environment env)
  (let ((first-type (if (constantp fobj env)
                        (type-of fobj)
                        (variable-type fobj env)))
        (second-type (if (constantp sobj env)
                         (type-of sobj)
                         (variable-type sobj env))))
    (if (%comparable-types-p first-type second-type)
        nil
        (error 'type-error
               :context "Objects of incompatible types cannot be equal"
               :datum second-type
               :expected-type first-type))
    form))


(defstore %%== (first second))


(defspecialization (%%== :inline t) ((first t) (second t)) (values boolean &optional)
  (equalp first second))

(defspecialization (%%== :inline t) ((first number) (second number)) (values boolean &optional)
  (= first second))

(defspecialization (%%== :inline t) ((first symbol) (second symbol)) (values boolean &optional)
  (eql first second))

(defspecialization (%%== :inline t) ((first character) (second character)) (values boolean &optional)
  (char= first second))

(defspecialization (%%== :inline t) ((first string) (second string)) (values boolean &optional)
  (string= first second))

(defspecialization (%%== :inline t) ((first sequence) (second sequence)) (values boolean &optional)
  (equalp first second))

(defspecialization (%%== :inline t) ((first structure-object) (second structure-object)) (values boolean &optional)
  (equalp first second))

(defspecialization (%%== :inline t) ((first hash-table) (second hash-table)) (values boolean &optional)
  (equalp first second))
