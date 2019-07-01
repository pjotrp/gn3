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
 SELECT DISTINCT ?wikidata_id
 WHERE {
  # hint:Query hint:optimizer "None" .
  ?wikidata_id wdt:P31 wd:Q7187 .
  ?s ps:P702 ?wikidata_id .
  ?wikidata_id rdfs:label "@gene_name"@"@"en .
 }
}
  )
                 
(define (sparql_homologene_id wikidata_id)
  @string-append{
 SELECT ?homologeneID
 WHERE
 {
  <@~a{@|wikidata_id|}> wdt:P593 ?homologeneID .
 } 
  }
)

(define (wikidata-json query)
  (call/input-url (string->url (string-append "https://query.wikidata.org/sparql?query=" (uri-encode query)))
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

(define (wikidata-values json)
 
  (map (lambda (wikidata_id)
         (hash-ref (hash-ref wikidata_id 'wikidata_id) 'value))
     (hash-ref (hash-ref json 'results) 'bindings))
       )
  

(require rackunit)

(test-case
 "tests"
 (display "Running tests...")
 (display sparql_homologene_id)
 (display (wikidata-string (sparql_wikidata_id "BRCA2")))
 (display (sparql_homologene_id "http://www.wikidata.org/entity/Q17853272"))
 (let ([json (wikidata-json (sparql_wikidata_id "BRCA2"))])
   (display json)
   (let ([values (wikidata-values json)])
     (display values)
     (writeln "---")
     (map (lambda (value)
            (wikidata-string (sparql_homologene_id value)))
            values))
   
   )
 ; (display (wikidata-json (sparql_wikidata_id "BRCA2")))
 
          ; (check-equal? (fetch "http://localhost:8000/") '("Hello GeneNetwork3!"))
          ; (check-equal? (fetch "http://localhost:8000/gene/aliases/BRCA2") '("BRCA2"))
          ; (display (fetch-string "http://localhost:8000/wikidata") )
          )
 