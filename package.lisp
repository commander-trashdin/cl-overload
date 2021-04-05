;;;; package.lisp

(defpackage #:cl-overload
  (:use #:cl #:adhoc-polymorphic-functions
        #:alexandria)
  (:local-nicknames (:cm :sandalphon.compiler-macro)
                    (:mop :closer-mop))
  (:shadow #:+ #:- #:* #:/
           #:= #:/=
           #:< #:> #:<= #:>=
           #:remove #:remove-if
           #:sort
           #:count #:count-if
           #:find #:find-if
           #:map #:reduce
           #:emptyp
           #:position #:position-if
           #:fill
           #:replace
           #:substitute
           #:substitute-if))
