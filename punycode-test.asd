#|
 This file is a part of punycode
 (c) 2023 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(asdf:defsystem punycode-test
  :version "1.0.0"
  :license "zlib"
  :author "Nicolas Hafner <shinmera@tymoon.eu>"
  :maintainer "Nicolas Hafner <shinmera@tymoon.eu>"
  :description "Tests for the punycode system."
  :homepage "https://shinmera.github.io/punycode/"
  :bug-tracker "https://github.com/shinmera/punycode/issues"
  :source-control (:git "https://github.com/shinmera/punycode.git")
  :serial T
  :components ((:file "test"))
  :depends-on (:punycode :parachute)
  :perform (asdf:test-op (op c) (uiop:symbol-call :parachute :test :org.shirakumo.punycode.test)))
