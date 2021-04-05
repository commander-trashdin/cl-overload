



(in-package :cl-overload)


(defmacro tbind* (bindings &body body)
  (labels ((rec (bindings)
             (if bindings
                 (destructuring-bind (bind . rest) bindings
                   (assert (and (listp bind) (<= (length bind) 4)))
                   (destructuring-bind (names . types-and-values) bind
                     (if (symbolp names)
                         (let ((typedec (member :t types-and-values)))
                           (if typedec
                               (if (null (cdr typedec))
                                   (setf types-and-values `(:t t :t)) ;;TODO ugly way of biding :t specifically
                                   (setf types-and-values (third typedec)))
                               (setf types-and-values (first types-and-values)))
                           `(let ((,names ,(or types-and-values
                                              (if typedec (default (second typedec))))))
                              (declare . ,(if typedec `((type ,(second typedec) ,names))))
                              ,(rec rest)))
                         (let ((typedec (member :t types-and-values)))
                           (if typedec
                               (setf types-and-values (third typedec))
                               (setf types-and-values (first types-and-values)))
                           `(multiple-value-bind ,names ,types-and-values
                              (declare . ,(if typedec
                                              (loop :for name :in names
                                                    :for type :in (second typedec)
                                                    :collect `(type ,type ,name))))
                              ,(rec rest))))))
                 `(progn ,@body))))
    (rec bindings)))





;;; Example of usage
;;; (tbind* ((x :t fixnum 10)
;;            (y :t string)
;;            ((a b) :t (fixnum fixnum) (floor 1000500 500))
;;     body)))
