(defvar *test-ids* (make-hash-table :test 'eql))
(defvar *test-names* (make-hash-table :test 'equalp)) 
(defvar *test-tags* (make-hash-table :test 'equalp))
(defvar *test-ids-paths* (make-hash-table :test 'eql))
(defvar *test-print-verbosity* nil)
(defvar *test-empty-function* (lambda () nil))
