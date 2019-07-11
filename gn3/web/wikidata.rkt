#lang at-exp racket

;; Wikidata fetchers

(provide wikidata-ids wikidata-gene-aliases gene-aliases)

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
(define wd-mouse "wd:Q83310")
(define wd-rat "wd:Q184224")
(define wd-gene "wd:Q7187")

(define (sparql_wikidata_id gene_name)
  @string-append{
     SELECT DISTINCT ?wikidata_id
            WHERE {
              ?wikidata_id @wdt-instance-of @wd-gene ;
                           @wdt-in-taxon ?species .
              VALUES (?species) { (@wd-human) (@wd-mouse) (@wd-rat) } .
              ?wikidata_id rdfs:label "@gene_name"@"@"en .
              }
            })

(define (sparql_gene_alias wikidata_id)
  @string-append{
SELECT DISTINCT ?alias
WHERE
{
    <@~a{@|wikidata_id|}> rdfs:label ?name ;
                         skos:altLabel ?alias .
   FILTER(LANG(?name) = "en" && LANG(?alias) = "en").
}}
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

(define (wikidata-values json fieldname)
  (map (lambda (wikidata_id)
         (hash-ref (hash-ref wikidata_id fieldname) 'value))
       (hash-ref (hash-ref json 'results) 'bindings))
  )

;; Get the wikidata_ids from a gene Name
(define (wikidata-ids gene-name)
  (let ([json (wikidata-json (sparql_wikidata_id gene-name))])
    (let ([values (wikidata-values json 'wikidata_id)])
      ; (display values)
      values
      )))

;; Get gene aliases for a wikidata_id
(define (wikidata-gene-aliases wikidata_id)
  (let ([aliases
         (wikidata-values (wikidata-json (sparql_gene_alias
                                          wikidata_id)) 'alias)])
    (filter-map (lambda (a) (and (not (string-contains? a " ")) a))
                aliases)))

;; Get gene aliases for a gene name
(define (gene-aliases gene-name)
  ""
  )
