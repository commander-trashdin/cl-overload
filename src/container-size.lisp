




(in-package :cl-overload)


;;Emptyp

(defpolymorph emptyp ((object array)) (values boolean &optional)
              (= 0 (cl:array-total-size object)))


(defpolymorph-compiler-macro emptyp (array) (object &environment env)
                             (let* ((type (cm:form-type object env))
                                    (dim (cm:array-type-dimensions type)))
                               (cond ((member type '(vector bit-vector string simple-string base-simple-string))
                                      `(= 0 (length ,object)))    ;; TODO this can probably be improved/less ugly
                                     ((eql dim 'cl:*)
                                      `(= 0 (cl:array-total-size ,object)))
                                     ((= 1 (cl:length dim))
                                      `(= 0 (length ,object)))
                                     (t `(= 0 (cl:array-total-size ,object))))))


(defpolymorph emptyp ((object list)) (values boolean &optional)
              (null object))


(defpolymorph emptyp ((object hash-table)) (values boolean &optional)
              (= 0 (hash-table-count object)))



;; Size
;; TODO Should emptyp use it? Maybe

(defpolymorph size ((object array)) (values ind &optional)
  (cl:array-total-size object))


(defpolymorph-compiler-macro size (array) (object &environment env)
  (let* ((type (cm:form-type object env))
         (dim (cm:array-type-dimensions type)))
    (cond ((member type '(vector bit-vector string simple-string base-simple-string))
           `(length ,object))    ;; TODO this can probably be improved/less ugly
          ((eql dim 'cl:*)
           `(cl:array-total-size ,object))
          ((= 1 (cl:length dim))
           `(length ,object))
          (t `(cl:array-total-size ,object)))))


(defpolymorph size ((object list)) (values ind &optional)
  (length object))


(defpolymorph size ((object hash-table)) (values ind &optional)
  (hash-table-count object))

;; Front/Back

(defpolymorph front ((container list)) t
              (first container))


(defpolymorph back ((container list)) t
              (car (last container)))


(defpolymorph front ((container array)) t
              (assert (= 1 (array-rank container)))
              (aref container 0))

(defpolymorph-compiler-macro front (array) (container &environment env)
  (let* ((type (cm:form-type container env))
         (elt-type  (cm:array-type-element-type type))
         (dim  (cm:array-type-dimensions type)))
    `(the (values ,elt-type &optional)
          (progn
            ,(cond ((eql dim 'cl:*)
                    (warn "An array should be of rank 1"))
                   ((> 1 (length dim))
                    (error "An array should be of rank 1")) ;;FIXME this doesn't trigger
                   (t t)) ;;instead sbcl check the aref against dimensions
            (aref ,container 0)))))                         ;; Not great, not terrible


(defpolymorph back ((container array)) t
              (assert (= 1 (array-rank container)))
              (aref container (1- (length container))))

(defpolymorph-compiler-macro back (array) (container &environment env)
  (let* ((type (cm:form-type container env))
         (elt-type  (cm:array-type-element-type type))
         (dim  (cm:array-type-dimensions type)))
    `(the (values,elt-type &optional)
          (progn
            ,(cond ((eql dim 'cl:*)
                    (warn "An array should be of rank 1"))
                   ((> 1 (length dim))
                    (error "An array should be of rank 1"))
                   (t t))
            ,(once-only (container)
                        `(aref ,container (1- (length ,container))))))))



;(defpolymorph (setf front) ((new t) (container list)) t
;              (setf (car container) new))
