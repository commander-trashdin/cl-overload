;;;; cl-overload.asd

(asdf:defsystem #:cl-overload
  :description "Common functions overload"
  :license  "MIT"
  :version "0.2"
  :serial t
  :depends-on (#:specialization-store #:introspect-environment)
  :components ((:file "package")
               (:module "src"
                :components
                ((:file "utility")
                 (:file "equality")
                 (:file "deep-copy")
                 (:file "cast")))))
