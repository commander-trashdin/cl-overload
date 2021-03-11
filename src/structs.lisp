;; Maybe it would have been better with MOP. But I am not good at MOP and also this is more of an example
;; of what kind of interface could be implemented. I would consider suggestions on how to improve this.
;; The goal is not to implement some kind of new object system, but rather provide a convenient
;; interface for an existing one, if neccesary.

(in-package :cl-overload)

(defmacro deftuple (name inheritance &rest slots)
  `(progn
     (defstruct ,(if inheritance `(,name (:include ,@inheritance)) name)
       ,@(loop :for (type sname . rest) :in slots
               :collect `(,sname
                           ,(or (first rest) (default type))
                          :type ,type)))
     (declaim (inline ,name))
     (defun ,name (&optional ,@(mapcar (lambda (slot) `(,(second slot) ,(or (third slot) (default (first slot)))))
                                       slots))
       (,(intern (concatenate 'string "MAKE-" (string name)))
        ,@(loop :for (type sname . rest) :in slots
                :collect (intern (string sname) "KEYWORD")
                :collect sname)))
     ,@(loop :for (type sname . rest) :in slots
             :collect `(progn
                         ,(unless (find-polymorphs sname)
                            `(define-polymorphic-function ,sname (object)))
                         (defpolymorph ,sname ((object ,name)) (values ,type &optional)
                           (,(intern (concatenate 'string (string name) "-" (string sname)))
                            object))))))




;; Example
;; (deftuple point (foo)
;;    (float Ox 1.0)
;;    (float Oy))))
