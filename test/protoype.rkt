#lang at-exp racket
(require json)
(require net/url)
(require net/uri-codec)

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

(define sparql_homologene_id
  @string-append{
 SELECT ?homologeneID
 WHERE
 {
  # wd:Q18247422 corresponds to Add1 in house mouse
  wd:Q18247422 wdt:P593 ?homologeneID .
    
  # an entire URI can be used, if it's wrapped in <>
  # <http://www.wikidata.org/entity/Q29723729> wdt:P593 ?homologeneID
 }

}
  )

(define wikidata-json
  (call/input-url (string->url (string-append "https://query.wikidata.org/sparql?query=" (uri-encode sparql_homologene_id)))
                  get-pure-port
                  (lambda (port)
                    (string->jsexpr (port->string port))
                    )
                  header
                  ))

(define wikidata-string
  (call/input-url (string->url (string-append "https://query.wikidata.org/sparql?query=" (uri-encode sparql_homologene_id)))
                  get-pure-port
                  port->string
                  header
                  ))

(require rackunit)

(test-case
 "tests"
 (display "Running tests...")
 (display sparql_homologene_id)
 (display wikidata-string)
 
 ; (check-equal? (fetch "http://localhost:8000/") '("Hello GeneNetwork3!"))
 ; (check-equal? (fetch "http://localhost:8000/gene/aliases/BRCA2") '("BRCA2"))
 ; (display (fetch-string "http://localhost:8000/wikidata") )
 )
