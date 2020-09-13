(in-package #:cl-overload)

(defspecialization (add :inline t) ((first number) (second number)) (values number &optional)
  (cl:+ first second))

(defspecialization (sub :inline t) ((first number) (second number)) (values number &optional)
  (cl:- first second))

(defspecialization (mul :inline t) ((first number) (second number)) (values number &optional)
  (cl:* first second))

(defspecialization (div :inline t) ((first number) (second number)) (values number &optional)
  (cl:/ first second))
