#|
 This file is a part of punycode
  (c) 2023 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(asdf:defsystem punycode
  :version "1.0.0"
  :license "zlib"
  :author "Nicolas Hafner <shinmera@tymoon.eu>"
  :maintainer "Nicolas Hafner <shinmera@tymoon.eu>"
  :description "Punycode encoding/decoding"
  :homepage "https://shinmera.github.io/punycode/"
  :bug-tracker "https://github.com/shinmera/punycode/issues"
  :source-control (:git "https://github.com/shinmera/punycode.git")
  :serial T
  :components ((:file "punycode"))
  :depends-on ()
  :in-order-to ((asdf:test-op (asdf:test-op :punycode-test))))
