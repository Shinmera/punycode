(asdf:defsystem punycode
  :version "1.0.0"
  :license "zlib"
  :author "Yukari Hafner <shinmera@tymoon.eu>"
  :maintainer "Yukari Hafner <shinmera@tymoon.eu>"
  :description "Punycode encoding/decoding"
  :homepage "https://shinmera.github.io/punycode/"
  :bug-tracker "https://github.com/shinmera/punycode/issues"
  :source-control (:git "https://github.com/shinmera/punycode.git")
  :serial T
  :components ((:file "punycode"))
  :depends-on ()
  :in-order-to ((asdf:test-op (asdf:test-op :punycode-test))))
