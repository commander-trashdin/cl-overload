;;;; cl-overload.asd

(asdf:defsystem #:cl-overload
    :description "Common functions overload"
    :license  "MIT"
    :version "0.2"
    :serial t
    :depends-on (#:adhoc-polymorphic-functions #:compiler-macro)
    :components ((:file "package")
                 (:module "src"
                          :components
                          ((:file "overload")
                           (:file "utility")
                           (:file "equality")
                           (:file "inequality")
                           (:file "arithmetics")
                           (:file "deep-copy")
                           (:file "cast")))))
