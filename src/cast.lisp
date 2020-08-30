(in-package #:cl-overload)

;;; Cast


(defstore cast (object type))


(defspecialization (cast :inline t) ((first bit) (second t)) (values boolean &optional)
  (declare (ignorable first second))
  (error 'simple-error)) ;; FIXME



(defspecialization (cast :inline t) ((first bit) (second (eql boolean))) (values boolean &optional)
  (declare (ignorable second))
  (/= 0 first))


(defspecialization (cast :inline t) ((first (mod 1114112)) (second (eql character))) (values character &optional)
  (declare (ignorable second))
  (code-char first))


(defspecialization (cast :inline t) ((first real) (second (eql float))) (values float &optional)
  (declare (ignorable second))  ;; TODO Think about distinction between single and double floats
  (float first))


(defspecialization (cast :inline t) ((first character) (second (eql number))) (values (mod 1114112) &optional)
  (declare (ignorable second))
  (char-code first))


(defspecialization (cast :inline t) ((first character) (second (eql string))) (values string &optional)
  (declare (ignorable second))
  (format nil "~a" first))
