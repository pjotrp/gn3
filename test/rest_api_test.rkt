#lang racket/base

(require rackunit)


(call/input-url (string->url "http://localhost:8000/gene/aliases/BRCA2")
                get-pure-port

               (lambda (port)
                  (string->jsexpr (port->string port)) )
)


(test-case
 "tests"
 (check-equal "curl http://localhost:8000/gene/aliases/BRCA2" "[\"BRCA2\"]")
 (check-equal? (length null) 1)
 )
