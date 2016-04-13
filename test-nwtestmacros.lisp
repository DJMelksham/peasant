(defun undefined-warning-p (w)
  (let ((control (simple-condition-format-control w)))
         (string= control "undefined ~(~A~): ~S")))

(locally
    (declare #+sbcl(sb-ext:muffle-conditions sb-kernel:redefinition-warning))
  (handler-bind
      (#+sbcl(sb-kernel:redefinition-warning #'muffle-warning))
   
    ))

(defmacro nwtest (&key 
		    name
		    description
		    source
		    (expectation "EQUALP")
		    expected-value
		    before-function-source
		    after-function-source)

      `(handler-bind
	   ((style-warning 
	     #'(lambda (w) 
		 (when (undefined-warning-p w)
		   (invoke-restart 'muffle-warning)))))
	 (make-test :name ,name
		    :description ,description
		    :expectation ,expectation
		    :source ',source
		    :expected-value ',expected-value
		    :before-function-source ',before-function-source
		    :after-function-source ',after-function-source)))

(defmacro nwtest-EQ (&key 
		   name
		   description
		   (source +)
		   (expected-value *)
		    before-function-source
		    after-function-source)
  `(make-test :name ,name
	      :description ,description
	      :expectation "EQ"
	      :source ',source
	      :expected-value ',expected-value
	      :before-function-source ',before-function-source
	      :after-function-source ',after-function-source))

(defmacro nwtest= (&key 
		   name
		   description
		   (source +)
		   (expected-value *)
		    before-function-source
		    after-function-source)
  `(make-test :name ,name
	      :description ,description
	      :expectation "="
	      :source ',source
	      :expected-value ',expected-value
	      :before-function-source ',before-function-source
	      :after-function-source ',after-function-source))

(defmacro nwtest-EQL (&key 
		   name
		   description
		   (source +)
		   (expected-value *)
		    before-function-source
		    after-function-source)
  `(make-test :name ,name
	      :description ,description
	      :expectation "EQL"
	      :source ',source
	      :expected-value ',expected-value
	      :before-function-source ',before-function-source
	      :after-function-source ',after-function-source))

(defmacro nwtest-EQUAL (&key 
		   name
		   description
		   (source +)
		   (expected-value *)
		    before-function-source
		    after-function-source)
  `(make-test :name ,name
	      :description ,description
	      :expectation "EQUAL"
	      :source ',source
	      :expected-value ',expected-value
	      :before-function-source ',before-function-source
	      :after-function-source ',after-function-source))

(defmacro nwtest-EQUALP (&key 
		   name
		   description
		   (source +)
		   (expected-value *)
		    before-function-source
		    after-function-source)
  `(make-test :name ,name
	      :description ,description
	      :expectation "EQUALP"
	      :source ',source
	      :expected-value ',expected-value
	      :before-function-source ',before-function-source
	      :after-function-source ',after-function-source))

(defmacro nwtest-NULL (&key 
		   name
		   description
		   (source +)
		   (expected-value *)
		    before-function-source
		    after-function-source)
  `

  (make-test :name ,name
	      :description ,description
	      :expectation "NULL"
	      :source ',source
	      :expected-value ',expected-value
	      :before-function-source ',before-function-source
	      :after-function-source ',after-function-source))

(defmacro nwtest-T (&key 
		   name
		   description
		   (source +)
		   (expected-value *)
		    before-function-source
		    after-function-source)
  `(make-test :name ,name
	      :description ,description
	      :expectation "T"
	      :source ',source
	      :expected-value ',expected-value
	      :before-function-source ',before-function-source
	      :after-function-source ',after-function-source))
