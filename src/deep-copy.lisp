(in-package #:cl-overload)


;; Deep-copy   --- is mediocre rn




(defpolymorph deep-copy ((o number)) number
              o)

(defpolymorph deep-copy ((o character)) character
              o)

(defpolymorph deep-copy ((o symbol)) symbol
              o)


(defpolymorph deep-copy ((o array)) array
  ;; Could consider more options like displacements
  (let ((r (make-array (array-dimensions o)
                       :element-type (array-element-type o)
                       :initial-element (default (array-element-type o)))))
    (loop :for i :below (array-total-size o)
          :do (setf (row-major-aref r i)
                    (deep-copy (row-major-aref o i))))
    r))

(defpolymorph-compiler-macro deep-copy (array) (o &environment env)
                             (let* ((o-type (cm:form-type o env))
                                    (o-elt  (cm:array-type-element-type o-type))
                                    (o-dim  (cm:array-type-dimensions o-type)))
                               `(the ,o-type
                                     ,(once-only (o)
                                                 `(let ((r (make-array ',o-dim
                                                                       :element-type ',o-elt
                                                                       ;; Further part may be handled by the compiler-macro
                                                                       ;; of DEFAULT
                                                                       :initial-element (default ',o-elt))))
                                                    (declare (type ,o-type ,o r))
                                                    (loop :for i :below ,(reduce #'* o-dim :initial-value 1) ;;Looks questionable, since not all dimensions are constant
                                                          :do (setf (row-major-aref r i)
                                                                    ;; Leave make-array and row-major-aref to be optimized by SBCL
                                                                    (the ,o-elt
                                                                         (deep-copy (the ,o-elt (row-major-aref ,o i))))))
                                                    r)))))


(defpolymorph deep-copy ((o cons)) (values cons &optional)
              (cons (deep-copy (car o)) (deep-copy (cdr o))))

(defpolymorph-compiler-macro deep-copy (cons) (o &environment env)
                             (let ((type (cm:form-type o env)))
                               (print `(the ,type
                                            ,(once-only (o)
                                                        `(cons (deep-copy (car ,o))
                                                               (deep-copy (cdr ,o))))))))

(defpolymorph deep-copy ((o structure-object)) (values structure-object &optional)
              (let* ((type        (type-of o))
                     (initializer (find-symbol (concatenate 'string
                                                            "MAKE-"
                                                            (symbol-name type))))
                     (slots (mop:class-slots (find-class type))))
                (apply initializer
                       (loop :for slot :in slots
                             :for name := (mop:slot-definition-name slot)
                             :for value := (slot-value o name)
                             :appending `(,(intern (symbol-name name) :keyword)
                                           ,(deep-copy value))))))

(defpolymorph-compiler-macro deep-copy (structure-object) (o &environment env)
                             ;; TODO: Handle the case when TYPE is something complicated: "satisfies"
                             (let* ((type        (cm:form-type o env))
                                    (initializer (find-symbol (concatenate 'string
                                                                           "MAKE-"
                                                                           (symbol-name type))))
                                    (slots (mop:class-slots (find-class type))))
                               (print `(the ,type
                                            (let ((o ,o))
                                              (declare (type ,type o))
                                              (,initializer
                                               ,@(loop :for slot :in slots
                                                       :for name := (mop:slot-definition-name slot)
                                                       :for slot-type := (mop:slot-definition-type slot)
                                                       :for value := `(slot-value o ',name)
                                                       :appending `(,(intern (symbol-name name) :keyword)
                                                                     (deep-copy (the ,slot-type ,value))))))))))
