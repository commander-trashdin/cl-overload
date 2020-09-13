(in-package #:cl-overload)



;; Utility

(defun 2arg->rest (name)
  (case name
    (add '+)
    (sub '-)
    (mul '*)
    (div '/)
    (less '<)
    (loq '<=)
    (same '=)))


(defmacro defspecialization (store-name specialized-lambda-list value-type &body body)
  (if (not (member store-name '(add sub mul div same less loq)))
      `(specialization-store:defspecialization ,store-name ,specialized-lambda-list
         ,value-type ,@body)
      (cond ((member store-name '(add mul))
             `(progn
                (specialization-store:defspecialization ,store-name ,specialized-lambda-list
                  ,value-type ,@body)
                (if (and (= 2 (length specialized-lambda-list))
                       (eql (cadar specialized-lambda-list) (cadadr specialized-lambda-list))))
                (let ((name (2arg->rest store-name)))
                  (specialization-store:define-specialization ,name
                      (&rest (args ,(cadar specialized-lambda-list)))
                    ,value-type
                    (:function (lambda (&rest objects)
                                 (reduce #',name objects)))
                    (:expand-function (compiler-macro-lambda (&whole form &rest objects &environment env)
                                                             (if (constantp (length objects) env)
                                                                 (reduce (lambda (a b) `(,name ,a ,b)) objects)
                                                                 form)))))))
            ((member store-name '(same less loq))
             `(progn
                (specialization-store:defspecialization ,store-name ,specialized-lambda-list
                  ,value-type ,@body)
                (if (and (= 2 (length specialized-lambda-list))
                       (eql (cadar specialized-lambda-list) (cadadr specialized-lambda-list))))
                (let ((name (2arg->rest store-name)))
                  (specialization-store:define-specialization ,name
                      (&rest (args ,(cadar specialized-lambda-list)))
                    ,value-type
                    (:function (lambda (&rest objects)
                                 (reduce #',name objects)))
                    (:expand-function (compiler-macro-lambda (&whole form &rest objects &environment env)
                                                             (if (constantp (length objects) env)
                                                                 (reduce (lambda (a b) `(,name ,a ,b)) objects)
                                                                 form))))))))))
