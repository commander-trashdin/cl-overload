(in-package #:cl-overload)



(define-specialization + (&rest (objects number)) (values number &optional)
  (:function (lambda (&rest objects)
               (apply #'cl:+ objects)))
  (:expand-function (compiler-macro-lambda (&whole form &rest objects &environment env)
                      (if (constantp (length objects) env)
                          `(cl:+ ,@objects)
                          form))))

(define-specialization * (&rest (objects number)) (values number &optional)
  (:function (lambda (&rest objects)
               (apply #'cl:* objects)))
  (:expand-function (compiler-macro-lambda (&whole form &rest objects &environment env)
                      (if (constantp (length objects) env)
                          `(cl:* ,@objects)
                          form))))


(define-specialization - ((object number) &rest (objects number)) (values number &optional)
  (:function (lambda (object &rest objects)
               (cl:- object (apply #'cl:+ objects))))
  (:expand-function (compiler-macro-lambda (&whole form object &rest objects &environment env)
                      (if (constantp (length objects) env)
                          `(cl:- ,object ,@objects)
                          form))))

(define-specialization / ((object number) &rest (objects number)) (values number &optional)
  (:function (lambda (object &rest objects)
               (cl:/ object (apply #'cl:* objects))))
  (:expand-function (compiler-macro-lambda (&whole form object &rest objects &environment env)
                      (if (constantp (length objects) env)
                          `(cl:/ ,object ,@objects)
                          form))))
