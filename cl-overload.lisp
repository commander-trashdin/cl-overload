;;;; cl-overload.lisp

(in-package #:cl-overload)



;; Utility

(defparameter *comparable* '((number number)))

;; TODO improve this hodge-podge type comparison
(defun %comparable-types-p (type1 type2)
  (cond
    ((or (eql type1 '*) (eql type2 '*)) t)
    ((or (eql type1 t) (eql type2 t)) t)             ;; TODO will probably need more ridiculous clauses in the fututre
    ((symbolp type1)
     (if (symbolp type2)
         (or (eql type1 type2)
            (loop :for (comp1 comp2) :in *comparable*
                    :thereis (or (and (subtypep type1 comp1)
                                   (subtypep type2 comp2))
                                (and (subtypep type1 comp2)
                                   (subtypep type2 comp1)))))
         (or (eql type1 (car type2))
            (loop :for (comp1 comp2) :in *comparable*
                    :thereis (or (and (subtypep type1 comp1)
                                   (subtypep (car type2) comp2))
                                (and (subtypep type1 comp2)
                                   (subtypep (car type2) comp1)))))))
    ((symbolp type2)
     (or (eql type2 (car type1))
        (loop :for (comp1 comp2) :in *comparable*
                :thereis (or (and (subtypep (car type1) comp1)
                               (subtypep type2 comp2))
                            (and (subtypep (car type1) comp2)
                               (subtypep type2 comp1))))))
    ((and (listp type1) (listp type2))
     (loop :for a :in type1
           :for b :in type2
           :always (%comparable-types-p a b)))))

     




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

