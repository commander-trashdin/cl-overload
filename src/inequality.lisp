(in-package #:cl-overload)



(defpolymorph < ((first real) (second real)) (values boolean &optional)
              (cL:< first second))

(defpolymorph <= ((first real) (second real)) (values boolean &optional)
              (cl:<= first second))

(defpolymorph < ((first character) (second character)) (values boolean &optional)
              (char< first second))

(defpolymorph <= ((first character) (second character)) (values boolean &optional)
              (char<= first second))

(defpolymorph < ((first string) (second string)) (values boolean &optional)
              (string< first second))

(defpolymorph <= ((first string) (second string)) (values boolean &optional)
              (string<= first second))




;;; Autodefinition


(declaim (inline > >=))
(defun > (first second)
  (not (<= first second)))
(defun >= (first second)
  (not (< first second)))
