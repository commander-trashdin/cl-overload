(in-package #:cl-overload)

;;; Cast
;; The big problem with cast is that type cannot be specified via something like
;; (type (eql boolean))
;; because apparently '(a) is not of type (eql (a))

;; TODO casts to strings -- should probably try to cast stuff to characters as well? But how?
;; There are at least 2 possibilities -- 1 turns into #\1 or into (code-char 1).
