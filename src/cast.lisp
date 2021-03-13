(in-package #:cl-overload)

;;; Cast

;; TODO casts to strings -- should probably try to cast stuff to characters as well? But how?
;; There are at least 2 possibilities -- 1 turns into #\1 or into (code-char 1).


(defpolymorph cast ((object number) (type (member number complex real float
                                                  single-float double-float
                                                  long-float short-float ratio
                                                  rational integer fixnum
                                                  bignum))) number
  (coerce object type))


(defpolymorph-compiler-macro cast (number (member number complex real
                                                  float single-float double-float
                                                  long-float short-float ratio rational
                                                  integer fixnum bignum))
  (object type)
  `(the ,(if (constantp type) (eval type) 'number) (coerce ,object ,type)))



(defpolymorph cast ((object list) (type (eql boolean))) boolean
  (declare (ignorable type))
  (not (null object)))


(defpolymorph cast ((object (mod 1114112)) (type (eql character))) character
  (declare (ignorable type))
  (code-char object))

(defpolymorph cast ((object character) (type (eql integer))) (mod 1114112)
  (declare (ignorable type))
  (char-code object))


(defpolymorph casr ((object bit) (type (eql boolean))) boolean
  (cl:= object 1))

(defpolymorph casr ((object boolean) (type (eql bit))) bit
  (if object 1 0))
