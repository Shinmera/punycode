#|
 This file is a part of punycode
 (c) 2023 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(defpackage #:org.shirakumo.punycode
  (:use #:cl)
  (:export
   #:encode
   #:decode
   #:encode-domain
   #:decode-domain))

(in-package #:org.shirakumo.punycode)

(defconstant INITIAL-N #x80)
(defconstant INITIAL-BIAS 72)
(defconstant BASE 36)
(defconstant TMAX 26)
(defconstant TMIN 1)
(defconstant SKEW 38)
(defconstant DAMP 700)

(defun encode-digit (code)
  (code-char (+ code (if (< code 26) 97 22))))

(defun adapt (delta num-points first-time-p)
  (setf delta (if first-time-p 
                  (truncate delta DAMP)
                  (ash delta -1)))
  (incf delta (truncate delta num-points))
  (loop for k from 0 by BASE
        while (< (ash (* TMAX (- BASE TMIN)) -1) delta)
        do (setf delta (truncate delta (- BASE TMIN)))
        finally (return (+ k (truncate (* delta (+ 1 (- BASE TMIN))) (+ delta SKEW))))))

(defmacro with-stream (stream-ish &body body)
  (let ((thunk (gensym "THUNK")))
    `(flet ((,thunk (,stream-ish)
              ,@body))
       (etypecase out
         (null
          (with-output-to-string (,stream-ish)
            (,thunk ,stream-ish)))
         ((eql T)
          (,thunk *standard-output*))
         (stream
          (,thunk ,stream-ish))))))

(defun encode (string &optional out)
  (with-stream out
    (let ((n INITIAL-N)
          (bias INITIAL-BIAS)
          (delta 0)
          (basic 0))
      (loop for i from 0 below (length string)
            for char = (char string i)
            for code = (char-code char)
            do (when (< code 128)
                 (write-char char out)
                 (incf basic)))
      (unless (= 0 basic)
        (write-char #\- out))
      (loop with handled = basic
            for m = most-positive-fixnum
            for handled+1 = (1+ handled)
            while (< handled (length string))
            do (loop for char across string
                     for code = (char-code char)
                     do (when (<= n code (1- m))
                          (setf m code)))
               (incf delta (* (- m n) handled+1))
               (setf n m)
               (loop for char across string
                     for code = (char-code char)
                     do (let ((q delta))
                          (when (< code n)
                            (incf delta))
                          (when (= n code)
                            (loop for k from BASE by BASE
                                  for tt = (cond ((<= k bias) TMIN)
                                                 ((<= (+ bias TMAX) k) TMAX)
                                                 (T (- k bias)))
                                  do (when (< q tt) (return))
                                     (write-char (encode-digit (+ tt (mod (- q tt) (- BASE tt)))) out)
                                     (setf q (truncate (- q tt) (- BASE tt))))
                            (write-char (encode-digit q) out)
                            (setf bias (adapt delta handled+1 (= handled basic)))
                            (setf delta 0)
                            (incf handled))))
               (incf delta)
               (incf n)))))

(defun decode-digit (char)
  (let ((code (char-code char)))
    (cond ((<= #x30 code #x39) (+ 26 (- code #x30)))
          ((<= #x41 code #x5A) (- code #x41))
          ((<= #x61 code #x7A) (- code #x61))
          (T BASE))))

(defun decode (string &optional out)
  (let* ((i 0)
         (n INITIAL-N)
         (bias INITIAL-BIAS)
         (basic (or (position #\- string :from-end T) 0))
         (written basic)
         (uni (make-array (length string) :element-type 'character)))
    ;; This is gross, I know. But we can't stream things out nicely because
    ;; later mixed codepoints can have the same target index, causing earlier
    ;; codepoints to be shifted downwards, which we obviously cannot do if we
    ;; already emitted the codepoint to stream. So we instead copy to a string
    ;; first.
    (loop for i from 0 below basic
          do (setf (char uni i) (char string i)))
    (flet ((insert (pos char)
             (loop for i downfrom written above pos
                   do (setf (char uni i) (char uni (1- i))))
             (setf (char uni pos) char)))
      (loop with in = (if (< 0 basic) (1+ basic) 0)
            for old-i = i
            while (< in (length string))
            do (loop with w = 1
                     for k from BASE by BASE
                     for digit = (decode-digit (char string in))
                     do (incf in)
                        (incf i (* digit w))
                        (let ((tt (cond ((<= k bias) TMIN)
                                        ((<= (+ bias TMAX) k) TMAX)
                                        (T (- k bias)))))
                          (when (< digit tt) (return))
                          (setf w (* w (- base tt)))))
               (incf written)
               (setf bias (adapt (- i old-i) written (= old-i 0)))
               (incf n (truncate i written))
               (setf i (mod i written))
               (insert i (code-char n))
               (incf i)))
    (with-stream out
      (write-string uni out :end written))))

(defun encode-domain (string &optional out)
  (cond ((loop for char across string
               thereis (<= 127 (char-code char)))
         (with-stream out
           (write-string "xn--" out)
           (encode string out)))
        (out
         (with-stream out 
           (write-string string out)))
        (T
         string)))

(defun decode-domain (string &optional out)
  (cond ((and (< (length "xn--") (length string))
              (string= "xn--" string :end2 (length "xn--"))))
        (out
         (with-stream out
           (write-string string out)))
        (T
         string)))
