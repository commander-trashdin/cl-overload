;;;; cl-overload.asd

(asdf:defsystem #:cl-overload
  :description "Common functions overload"
  :author "aun aun.sokolov@gmail.com>"
  :license  "MIT"
  :version "0.1"
  :serial t
  :depends-on (#:specialization-store #:introspect-environment)
  :components ((:file "package")
               (:file "cl-overload")))
