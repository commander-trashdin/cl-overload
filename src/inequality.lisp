(in-package #:cl-overload)



(defspecialization (< :inline t) ((first number) (second number)) (values boolean &optional)
  (cL:< first second))

(defspecialization (<= :inline t) ((first number) (second number)) (values boolean &optional)
  (cl:<= first second))

(defspecialization (< :inline t) ((first character) (second character)) (values boolean &optional)
  (char< first second))

(defspecialization (<= :inline t) ((first character) (second character)) (values boolean &optional)
  (char<= first second))

(defspecialization (< :inline t) ((first string) (second string)) (values boolean &optional)
  (string< first second))

(defspecialization (<= :inline t) ((first string) (second string)) (values boolean &optional)
  (string<= first second))




;;; Autodefinition


(declaim (inline > >=))
(defun > (first second)
  (not (<= first second)))
(defun >= (first second)
  (not (< first second)))
