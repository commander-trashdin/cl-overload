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
