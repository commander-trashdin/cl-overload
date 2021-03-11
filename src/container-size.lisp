




(in-package :cl-overload)


;;Emptyp

(defpolymorph emptyp ((object vector)) (values boolean &optional)
              (= 0 (cl:length object)))


(defpolymorph emptyp ((object list)) (values boolean &optional)
              (null object))


(defpolymorph emptyp ((object hash-table)) (values boolean &optional)
              (= 0 (hash-table-count object)))



;; Size
;; TODO Should emptyp use it? Maybe

(defpolymorph size ((object array)) (values ind &optional)
  (typecase object
    ((or vector bit-vector string) (cl:length object))
    (otherwise (cl:array-total-size object))))

(defpolymorph-compiler-macro size (array) (object &environment env)
  (let* ((type (cm:form-type object env)))
    (cond ((subtypep type '(or vector bit-vector string) env)
           `(length ,object))    ;; TODO this can probably be improved/less ugly
          (t `(cl:array-total-size ,object)))))


(defpolymorph capacity ((object array)) (values ind &optional)
  (cl:array-total-size object))

(defpolymorph size ((object list)) (values ind &optional)
  (length object))


(defpolymorph size ((object hash-table)) (values ind &optional)
  (hash-table-count object))

;; Front/Back

(defpolymorph front ((container list)) t
  (first container))


(defpolymorph (setf front) ((new t) (container list)) t
  (setf (first container) new))

(defpolymorph back ((container list)) t
  (car (last container)))

(defpolymorph (setf back) ((new t) (container list)) t
  (setf (first (last container)) new))


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

(defpolymorph (setf front) ((new t) (container array)) t
  (setf (aref container 0) new))



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

