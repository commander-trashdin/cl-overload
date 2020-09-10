(in-package #:cl-overload)

(defstore cast (object type))

(defstore deep-copy (object))

(defstore = (first second)) ;; /= is autodefined

(defstore < (first second)) ;; same here for > and >=
(defstore <= (first second))




(defstore elem (container key))  ;; FIXME need a better name, this is accessor for container by the key
(defstore (setf elem) (new container))


(defstore + (&rest objects))
(defstore * (&rest objects))
(defstore - (object &rest objects))
(defstore / (object &rest objects))
