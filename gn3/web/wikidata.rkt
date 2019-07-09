#lang at-exp racket

;; Wikidata fetchers

(require json)
(require net/url)
(require net/uri-codec)

;;; header
(define header
  '("Accept: application/json"))

(define ps-encoded-by "ps:P702")
(define wdt-instance-of "wdt:P31")
(define wdt-in-taxon "wdt:P703")
(define wd-human "wd:Q15978631")
(define wd-gene "wd:Q7187")

(define (sparql_wikidata_id gene_name)
  @string-append{
     SELECT DISTINCT ?wikidata_id
            WHERE {
              ?wikidata_id @wdt-instance-of @wd-gene .
              ?wikidata_id @wdt-in-taxon @wd-human .
              ?wikidata_id rdfs:label "@gene_name"@"@"en .
              }
            })

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

(define (wikidata-values json fieldname)
  (map (lambda (wikidata_id)
         (hash-ref (hash-ref wikidata_id fieldname) 'value))
       (hash-ref (hash-ref json 'results) 'bindings))
  )


(define wikidata_id
  (let ([json (wikidata-json (sparql_wikidata_id "BRCA2"))])
    (let ([values (wikidata-values json 'wikidata_id)])
      (display values))))
