;;;; Highly experimental!


(in-package #:cl-overload)


%comparable-types-p(declaim (inline slot-value))
(defun slot-value (object slot-name)
  (cl:slot-value object slot-name))


(define-compiler-macro slot-value (&whole form object slot-name &environment env)
  (if (constantp slot-name env)
      (let ((expanded-object (macroexpand object env)))
        (let ((known-type (if (atom expanded-object)
                              (introspect-environment:variable-type expanded-object)
                              (if (eql (car expanded-object) 'the)
                                  (second expanded-object)
                                  (second (third (introspect-environment:function-type (car expanded-object))))))))
          (if (subtypep known-type 'structure-object)  ;; FIXME handle that find-class error, otherwise it's alpha version
              (let ((slot-type
                      (loop :for slot :in (closer-mop:class-slots (find-class known-type)) ;; if this errors, everything breaks
                            :when (eql (eval slot-name) (closer-mop:slot-definition-name slot))
                              :do (return (closer-mop:slot-definition-type slot)))))
                 (if slot-type
                     `(the ,slot-type (cl:slot-value ,object ,slot-name))
                     form))
              form)))
      form))
