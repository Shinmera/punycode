(asdf:defsystem punycode-test
  :version "1.0.0"
  :license "zlib"
  :author "Yukari Hafner <shinmera@tymoon.eu>"
  :maintainer "Yukari Hafner <shinmera@tymoon.eu>"
  :description "Tests for the punycode system."
  :homepage "https://shinmera.com/docs/punycode/"
  :bug-tracker "https://shinmera.com/project/punycode/issues"
  :source-control (:git "https://shinmera.com/project/punycode.git")
  :serial T
  :components ((:file "test"))
  :depends-on (:punycode :parachute)
  :perform (asdf:test-op (op c) (uiop:symbol-call :parachute :test :org.shirakumo.punycode.test)))
