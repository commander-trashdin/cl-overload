(in-package #:cl-overload)


;; Equality

(defun == (first second &rest objects)
  (every (lambda (b) (%== first b)) (cons second objects)))

(defun =/= (first second &rest objects)
  (some (lambda (b) (not (%== first b))) (cons second objects)))

(define-compiler-macro == (&whole form first second &rest objects &environment env)
  (if (constantp (length objects) env)
      (case (length objects)
        (0 `(%== ,first ,second))
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
                        (if (atom fobj)
                            (variable-type fobj env)
                            t)))                         ;; TODO yeah this is the place where I need form-type;(
                                                         ;; Probably should adress at least direct function calls
        (second-type (if (constantp sobj env)
                         (type-of sobj)
                         (if (atom sobj)
                             (variable-type sobj env)
                             t))))
    (if (%comparable-types-p first-type second-type)
        nil
        (error 'type-error
               :context "Objects of incompatible types cannot be equal"
               :datum second-type
               :expected-type first-type))
    form))


(defstore %%== (first second))


;(defspecialization (%%== :inline t) ((first t) (second t)) (values boolean &optional)
;  (equalp first second))

(defspecialization (%%== :inline t) ((first number) (second number)) (values boolean &optional)
  (= first second))

(defspecialization (%%== :inline t) ((first symbol) (second symbol)) (values boolean &optional)
  (eql first second))

(defspecialization (%%== :inline t) ((first character) (second character)) (values boolean &optional)
  (char= first second))

(defspecialization (%%== :inline t) ((first string) (second string)) (values boolean &optional)
  (string= first second))

(define-specialization %%== ((first cons) (second cons)) (values boolean &optional)
  (:function (lambda (first second)
               (and (== (car first) (car second))
                  (== (cdr first) (cdr second)))))
  (:expand-function (compiler-macro-lambda (&whole form first second &environment env)
                      (if (and (constantp first env) (constantp second env))
                          (and (== (car first) (car second))
                             (== (cdr first) (cdr second)))
                          form))))

(define-specialization %%== ((first vector) (second vector)) (values boolean &optional)
  (:function (lambda (first second)
               (and (= (array-total-size first) (array-total-size second))
                  (loop :for ind :from 0 :below (array-total-size second)
                        :always (== (row-major-aref first ind)
                                    (row-major-aref second ind))))))
  (:expand-function (compiler-macro-lambda (&whole form first second &environment env)
                      (if (and (constantp first env) (constantp second env))
                          (and (= (array-total-size first) (array-total-size second))
                             (loop :for ind :from 0 :below (array-total-size second)
                                   :always (== (row-major-aref first ind)
                                               (row-major-aref second ind))))
                          form))))

(defspecialization (%%== :inline t) ((first hash-table) (second hash-table)) (values boolean &optional)
  (loop :for k1 :being :each :hash-key :of first
          :using (hash-value v1)
        :do (multiple-value-bind (v2 exists) (gethash k1 second)
              (unless (and exists (== v1 v2))
                (return nil)))
        :finally (return t)))


(defmacro define== ((first-name first-type) (second-name second-type) &body body)
  (if (typep body
             '(cons
               (cons (eql :function) t)
               (cons (cons (eql :expand-function) t) null)))
      `(define-specialization %%== ((,first-name ,first-type) (,second-name ,second-type))
           (values boolean &optional)
         ,@body)
      `(defspecialization %%== ((,first-name ,first-type) (,second-name ,second-type))
           (values boolean &optional)
         ,@body)))
