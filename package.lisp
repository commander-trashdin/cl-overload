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
           #:>=))  ;; TODO add more
