(declaim (optimize debug))
(load "cl-tap.lisp")

(defparameter *tester* (make-instance 'tester))

(plan *tester* 1)

(ok *tester* nil "Message")
(diag *tester* "Hi\nThere\n")
