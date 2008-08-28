;;; A Lisp implementation of TAP, the Test-Anything-Protocol:
;;;
;;; http://testanything.org/
;;;
;;; Very ad-hoc so far.
;;; 
;;; This code is distributed under the MIT/X11 license:
;;; 
;;; http://www.opensource.org/licenses/mit-license.php
;;;
;;; Copyright by Shlomi Fish, 2008

(defclass tester ()
  ((num-planned
    :reader num-planned
    :writer (setf num-planned))
   (curr-test
     :initform 0
     :reader curr-test
     :writer (setf curr-test))))

(defmethod ok ((self tester) value &optional msg)
  (format t "~a" (if value "ok" "not ok"))
  (format t "~a" " ")
  (incf (curr-test self))
  (format t (curr-test self))
  (if msg
    (format t "~a~a" "- " msg))
  (format t "~%")
  value)

(defmethod plan ((self tester) num)
  (setf (num-planned self) num)
  (format t "1..~a~%" num))

; (with (curr-test 0 num-planned 0)
;       (def ok (value (o msg))
;            (if value (pr "ok") (pr "not ok"))
;            (pr " ")
;            (pr (++ curr-test))
;            (pr " ")
;            (if msg (pr "- " msg))
;            (prn)
;            value)
;       (def chomp (s)
;            (let l (len s)
;              (cut s 0 (- l (if (is (s (- l 1)) #\Newline) 1 0)))))
;       (def diag (msg)
;            (let lines (ssplit (chomp msg) [ is _ #\Newline ])
;              (each l lines
;                    (w/stdout (stderr)
;                              (prn "# " l)))))
;       (def plan (num)
;            (= num-planned num)
;            (prn "1.." num))
;       (def swrite (v)
;            (tostring (write v)))
;       (def test-is (got expected (o msg))
;            (with (verdict (ok (is got expected) msg))
;                  (if (not verdict)
;                      (do (diag (tostring (prn "  Failed test '" msg "'")))
;                          (diag (+ "         got: " (swrite got)))
;                          (diag (+ "    expected: " (swrite expected)))))
;                  verdict))
;       (def test-iso (got expected (o msg))
;            (with (verdict (ok (iso got expected) msg))
;                  (if (not verdict)
;                      (do (diag (tostring (prn "  Failed test '" msg "'")))
;                          (diag (+ "         got: " (swrite got)))
;                          (diag (+ "    expected: " (swrite expected)))))
;                  verdict))
;       (def is-deeply (got expected (o msg))
;            (test-iso got expected msg)))
