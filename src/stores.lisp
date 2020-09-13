(in-package #:cl-overload)

(defstore cast (object type))

(defstore deep-copy (object))

(defstore same (first second))  ;; 2arg version of =

(defstore less (first second))
(defstore loq (first second))


(defstore = (first second)) ;; /= is autodefined

(defstore < (first second)) ;; same here for > and >=
(defstore <= (first second))




(defstore at (container key))  ;; FIXME need a better name, this is accessor for container by the key
(defstore (setf at) (new container))


(defstore add (first second))  ;; 2arg versions of arithmetics
(defstore sub (first second))
(defstore neg (first))
(defstore mul (first second))
(defstore div (first second))
(defstore inv (first))


(defstore + (&rest objects))
(defstore * (&rest objects))
(defstore - (object &rest objects))
(defstore / (object &rest objects))

;;(defstore slot-value (object slot-name))
;;(defstore (setf slot-value) (newvalue object slot-name))


(defstore default (typename))
