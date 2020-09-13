;;;; package.lisp

(defpackage #:cl-overload
  (:use #:cl #:specialization-store #:introspect-environment)
  (:shadow #:+
           #:-
           #:*
           #:/
           #:=
           #:/=
           #:<
           #:>
           #:<=
           #:>=
           #:slot-value
           #:defstruct))
          ; #:defspecialization))  ;; TODO add more
