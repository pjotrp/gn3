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

(define (sparql_wikidata_id gene_name)
  @string-append{
 SELECT DISTINCT ?geneid ?label
 WHERE {
  # hint:Query hint:optimizer "None" .
  ?geneid wdt:P31 wd:Q7187 .
  ?s ps:P702 ?geneid .
  ?geneid rdfs:label "BRCA1"@"@"en .
 }
}
  )
                 
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

(define (wikidata-string query)
  (call/input-url (string->url (string-append "https://query.wikidata.org/sparql?query=" (uri-encode query)))
                  get-pure-port
                  port->string
                  header
                  ))

(require rackunit)

(test-case
 "tests"
 (display "Running tests...")
 (display sparql_homologene_id)
 (display (wikidata-string (sparql_wikidata_id "BRCA2")))
          ; (check-equal? (fetch "http://localhost:8000/") '("Hello GeneNetwork3!"))
          ; (check-equal? (fetch "http://localhost:8000/gene/aliases/BRCA2") '("BRCA2"))
          ; (display (fetch-string "http://localhost:8000/wikidata") )
          )
 