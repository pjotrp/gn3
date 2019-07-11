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
 SELECT ?homologene_id
 WHERE
 {
  <@~a{@|wikidata_id|}> wdt:P593 ?homologene_id .
 }
  }
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
   (let ([values (wikidata-values json 'wikidata_id)])
     (display values)
     (writeln "---")
     ; (display (wikidata-string (sparql_homologene_id "http://www.wikidata.org/entity/Q17853272")) 'homologene_id)
     (display (map (lambda (value)
            (wikidata-values (wikidata-json (sparql_homologene_id value)) 'homologene_id))
            values)))
    (writeln (gene-aliases "http://www.wikidata.org/entity/Q17853272"))

   )
