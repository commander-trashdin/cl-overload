(in-package #:cl-overload)



;; Utility


(deftype ind () `(integer 0 #.array-dimension-limit))
(deftype typed-ht (key value) `hash-table)           ;; this is a HACK

(defparameter *default-impl* (make-hash-table))



(defun %dimensions-comp (dimensions)
  (cond ((eql '* dimensions) 0)
        ((listp dimensions) (mapcar (lambda (x) (if (eql '* x) 0 x)) dimensions))
        (t dimensions)))


(defun default (type &optional environment)
  (multiple-value-bind (item knownp) (gethash type *default-impl*)
    (if knownp
        item
        (progn
          (setf type (sb-ext:typexpand type environment))
          (if (symbolp type)
              (case type
                ((bit fixnum integer rational) 0)
                ((float double-float single-float long-float real) 0.0)
                ((number complex) #c(0 0))
                ((character base-char) #\Nul)
                (standard-char #\a)
                ((symbol t) t)
                (keyword :t)
                (hash-table `(make-hash-table))
                ((list boolean atom null) nil)
                (pathname #P"")
                (function '(lambda (&rest args)
                            (declare (ignore args)
                             (optimize (speed 3) (safety 0) (debug 0) (space 0) (compilation-speed 0)))))
                (vector '(make-array 0 :adjustable t))
                (bit-vector '(make-array 0 :element-type 'bit :adjustable t))
                (string '(make-array 0 :element-type 'character :adjustable t :initial-element #\Nul))
                (simple-array (make-array 0)) ;;Maybe it should error here, since array dimension is nto specified?
                ;;What happens with just array? Or just sequence? I guess nothing
                (simple-string '(make-array 0 :element-type 'character :initial-element #\Nul))
                (simple-base-string '(make-array 0 :element-type 'base-char :initial-element #\Nul))
                (otherwise
                 (cond ((subtypep type 'structure-object environment)
                        (list (intern (concatenate 'string "MAKE-" (string type)))))
                       ((subtypep type 'standard-object environment)
                        `(make-instance ,type)))))
              (destructuring-bind (main . rest) type
                (case main
                  ((mod unsigned-byte singned-byte) 0)
                  ((integer eql member rational real float) (first rest))
                  (complex `(complex ,(default (first rest)) ,(default (first rest))))
                  (cons `(cons ,(default (first rest)) ,(default (first rest))))
                  (or (default (first rest)))
                  (vector `(make-array ',(if (= 2 (length rest))
                                             (%dimensions-comp (second rest))
                                             0)
                                       :adjustable t
                                       :element-type ',(or (first rest) t)
                                       :initial-element ,(if (first rest)
                                                             (default (first rest))
                                                             0)))
                  (bit-vector `(make-array ,(or (first rest) 0) :element-type 'bit :adjustable t))
                  (string `(make-array ',(if (= 2 (length rest))
                                             (%dimensions-comp (second rest))
                                             0)
                                       :element-type 'character
                                       :adjustable t
                                       :initial-element #\Nul))
                  (simple-array `(make-array ',(if (= 2 (length rest))
                                                   (%dimensions-comp (second rest))
                                                   0)
                                             :element-type ',(or (first rest) t)
                                             :initial-element ,(if (first rest)
                                                                   (default (first rest))
                                                                   0)))
                  (simple-string `(make-array ',(if (= 2 (length rest))
                                                    (%dimensions-comp (second rest))
                                                    0)
                                              :element-type 'character
                                              :initial-element #\Nul))
                  (simple-base-string `(make-array ',(if (= 2 (length rest))
                                                         (%dimensions-comp (second rest))
                                                         0)
                                                   :element-type 'base-char
                                                   :initial-element #\Nul))

                  (array `(make-array ',(if (= 2 (length rest))
                                            (%dimensions-comp (second rest))
                                            0)
                                      :element-type ',(or (first rest) t)
                                      :initial-element ,(if (first rest)
                                                            (default (first rest))
                                                            0))))))))))





(defmacro zapf (place expr)
  (multiple-value-bind
        (temps exprs stores store-expr access-expr)
      (get-setf-expansion place)
    `(let* (,@(mapcar #'list temps exprs)
            (,(car stores)
              (let ((% ,access-expr))
                ,expr)))
       ,store-expr)))
