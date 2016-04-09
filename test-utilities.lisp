(defun hash-ext-array-insert (key value hash)
  (if (nth-value 1 (gethash key hash))
      (vector-push-extend value (gethash key hash))
      (setf (gethash key hash) (make-array 1  
					   :initial-element value
					   :adjustable t
					   :fill-pointer 1)))
      (fill-pointer (gethash key hash)))

(defun hash-ext-array-remove (key value hash)
  (if (nth-value 1 (gethash key hash))
      (progn 
	(setf (gethash key hash) (delete value (gethash key hash)))
	(if (= 0 (fill-pointer (gethash key hash)))
	    (remhash key hash)
	    T))))



(let ((x 0))
  (defun new-test-id ()
    (if (boundp '*test-ids*)
	(loop until (null (nth-value 1 (gethash x *test-ids*)))
	   do (incf x))
	(incf x))
    x)
  
  (defun set-test-id-counter (number)
    (if (and (not (integerp number))
	     (< 0 number))
	nil
	(setf x number))))

(defun test-cond (test-identifier)
  (cond ((integerp test-identifier) 
	 (gethash test-identifier *test-ids*))
	((or (stringp test-identifier) (symbolp test-identifier)) 
	 (gethash (string-upcase test-identifier) *test-names*))
	((typep test-identifier 'test)
	 test-identifier)
	(t nil)))

(defun tag-cond (tag-identifier)
  (cond ((and (not (listp tag-identifier))
	      (not (stringp tag-identifier))
	      (notevery #'stringp tag-identifier)) 
	   nil)
	  ((stringp tag-identifier) 
	   (list (string-upcase tag-identifier)))
	  ((typep tag-identifier 'sequence) 
	   (remove-duplicates (map 'list #'string-upcase tag-identifier) :test #'equalp))
	  (t nil)))
	      
(defun fetch-tests (test-identifier)
  (let* ((result nil))
    
    (if (null test-identifier)
	(return-from fetch-tests nil))

    (if (or (not (typep test-identifier 'sequence))
	    (typep test-identifier 'string))
	(setf result (make-array 1 :initial-element (test-cond test-identifier)))
	(setf result (map 'vector #'test-cond test-identifier)))
    (remove-duplicates result :test #'eq)))
    
(defun fetch-tests-from-tags (tag-identifiers)
  (let ((result (loop for tags in (tag-cond tag-identifiers)
		   unless (null (gethash tags *test-tags*))
		   collect (gethash tags *test-tags*))))

    (remove-duplicates (apply #'concatenate 'vector result) :test #'eq)))

(defun combine-test-sequences (&rest test-sequences)
 (remove nil 
	 (remove-duplicates 
	  (apply #'concatenate 'vector 
		 (map 'list #'fetch-tests test-sequences)) 
	  :test #'eq)))

(defun run-tests (test-sequence &key (re-evaluate 'auto))
  (cond ((eq re-evaluate 'auto) (map 'vector #'run-test (fetch-tests test-sequence)))
	((eq re-evaluate t) (map 'vector #'run-test-re-evaluate (fetch-tests test-sequence)))
	((eq re-evaluate nil) (map 'vector #'run-test-no-evaluate (fetch-tests test-sequence)))
	(t (map 'vector #'run-test (fetch-tests test-sequence)))))

(defun run-tags (tags)
  (map 'vector #'run-test (fetch-tests-from-tags tags)))

(defun tests-if (predicate-func test-sequence)
  (remove-if-not predicate-func (fetch-tests test-sequence)))

(defun tests-if-not (predicate-func test-sequence)
  (remove-if predicate-func (fetch-tests test-sequence)))

(defun map-tests (func test-sequence &key (result-type 'vector))
  (map result-type func (fetch-tests test-sequence)))

(defun failed-tests (test-sequence)
  (tests-if (lambda (x) (equal (result x) nil)) test-sequence))

(defun passed-tests (test-sequence)
  (tests-if (lambda (x) (equal (result x) t)) test-sequence))

(defun failing-tests (test-sequence)
  (failed-tests test-sequence))
(defun passing-tests (test-sequence)
  (passed-tests test-sequence))

(defun low-verbosity ()
  (setf *print-verbosity* 'low))

(defun high-verbosity ()
  (setf *print-verbosity* 'high))

(defun medium-verbosity ()
  (setf *print-verbosity* 'medium))

(defun all-tests (&key (verbosity *print-verbosity*))
 (let ((*print-verbosity* verbosity)) 
  (map 'vector #'identity (loop for tests being the hash-values in *test-ids*
			     collect tests))))

(defun detail-tests (test-sequence)
  (let ((*print-verbosity* 'high))
    (fetch-tests test-sequence)))

(defun print-results (&optional test-sequence (stream t))
  
  (let ((tests (fetch-tests (if test-sequence
				test-sequence
				(all-tests)))))
    (loop 
       for test across tests
       for result = (result test) then (result test)
       for id = (id test) then (id test)
       for position = 1 then (incf position)

       do (if (equal result t)
	      (format stream ".")
	      (progn (setf position 0)
		     (format stream "~&~a~&" (id test))))
       do (if (> position 50)
	      (progn
		(setf position 0)
		(format stream "~&"))))
    
    tests))


(defmacro with-gensyms (syms &body body)
  `(let ,(loop for s in syms collect `(,s (gensym)))
    ,@body))

(defmacro once-only ((&rest names) &body body)
  (let ((gensyms (loop for n in names collect (gensym))))
    `(let (,@(loop for g in gensyms collect `(,g (gensym))))
      `(let (,,@(loop for g in gensyms for n in names collect ``(,,g ,,n)))
        ,(let (,@(loop for n in names for g in gensyms collect `(,n ,g)))
           ,@body)))))
