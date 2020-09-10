(in-package #:cl-overload)

;;; Cast


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


(defspecialization (cast :inline t) ((first vector) (second (eql list))) (values list &optional)
  (declare (ignorable second))
  (coerce first 'list))

(defspecialization (cast :inline t) ((first list) (second (eql vector))) (values vector &optional)
  (declare (ignorable second))
  (coerce first second))


;; TODO casts to strings -- should probably try to cast stuff to characters as well? But how?
;; There are at least 2 possibilities -- 1 turns into #\1 or into (code-char 1).
