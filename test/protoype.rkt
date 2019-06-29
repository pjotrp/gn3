#lang racket
(require json)
(require net/url)

(define (fetch url)
  (call/input-url (string->url url)
                  get-pure-port
           
                  (lambda (port)
                    (string->jsexpr (port->string port))
                    )
                  ))

(define (fetch-string url)
  (call/input-url (string->url url)
                  get-pure-port
           
               
                  port->string)
  )

;;; header
(define header 
 '("Accept: application/json"))


(define wikidata
       (call/input-url (string->url "https://query.wikidata.org/sparql?query=SELECT %3FhomologeneID%0AWHERE%0A{%0A%20%20%20 %23 wd%3AQ18247422 corresponds to Add1 in house mouse%0A%20%20%20 wd%3AQ18247422 wdt%3AP593 %3FhomologeneID .%0A%20%20%20%20%0A%20%20%20 %23 an entire URI can be used%2C if it's wrapped in <>%0A%20%20%20 %23 <http%3A%2F%2Fwww.wikidata.org%2Fentity%2FQ29723729> wdt%3AP593 %3FhomologeneID%0A}%0A%0A")
                       get-pure-port
                       port->string
                       header
                       ))

(require rackunit)

(test-case
 "tests"
 (display "Running tests...")
 (display wikidata )
 ; (check-equal? (fetch "http://localhost:8000/") '("Hello GeneNetwork3!"))
 ; (check-equal? (fetch "http://localhost:8000/gene/aliases/BRCA2") '("BRCA2"))
 ; (display (fetch-string "http://localhost:8000/wikidata") )
 )
