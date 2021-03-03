;;;; package.lisp

(defpackage #:cl-overload
  (:use #:cl #:adhoc-polymorphic-functions
        #:alexandria)
  (:local-nicknames (:cm :sandalphon.compiler-macro)
                    (:mop :closer-mop))
  (:shadow #:+
           #:-
           #:*
           #:/
           #:=
           #:/=
           #:<
           #:>
           #:<=
           #:>=))
