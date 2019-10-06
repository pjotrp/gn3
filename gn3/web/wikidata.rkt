#lang at-exp racket

;; Wikidata fetchers
;;
;; The end points use a simpile memoize routine which is reset by restarting the
;; process.
;;

(provide sparql_gene_alias
         wikidata-ids
         wikidata-gene-aliases
         gene-aliases
         gene-aliases2)

(require json)
(require net/url)
(require net/uri-codec)
(require memo)

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

;; Create a SPARQL query for fetching wikidata ids for a (case
;; sensitive) gene name (in Human Mouse and Rat) e.g.
#|
SELECT DISTINCT ?wikidata_id
       WHERE {
         ?wikidata_id wdt:P31 wd:Q7187 ;
                      wdt:P703 ?species .
         VALUES (?species) { (wd:Q15978631) (wd:Q83310) (wd:Q184224) } .
         ?wikidata_id rdfs:label "BRCA2"@en .
         }
|#

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

;; Create a SPARQL query for fetching aliases that go with a wikidata
;; id (within species) e.g. for Human BRCA2,
;;
#|
SELECT DISTINCT ?alias
       WHERE {
               <http://www.wikidata.org/entity/Q17853272> rdfs:label ?name ;
               skos:altLabel ?alias .
               FILTER(LANG(?name) = "en" && LANG(?alias) = "en").
             }
|#

(define (sparql_gene_alias wikidata_id)
  @string-append{
      SELECT DISTINCT ?alias
             WHERE {
                    <@~a{@|wikidata_id|}> rdfs:label ?name ;
                        skos:altLabel ?alias .
      FILTER(LANG(?name) = "en" && LANG(?alias) = "en").
      }}
  )

;; Execute a Wikidata SPARQL query and return as JSON expression
(define (wikidata-json query)
  (call/input-url (string->url (string-append "https://query.wikidata.org/sparql?query=" (uri-encode query)))
                  get-pure-port
                  (lambda (port)
                    (string->jsexpr (port->string port))
                    )
                  header
                  ))

; (wikidata-xml (sparql_wikidata_id "Shh"))
(define (wikidata-xml query)
  (call/input-url (string->url (string-append "https://query.wikidata.org/sparql?query=" (uri-encode query)))
                  get-pure-port
                  port->string
                  '("Accept: application/xml")
                  ))


;; Execute a Wikidata SPARQL query and return as a string (mostly for
;; debugging purposes)
(define (wikidata-string query)
  (call/input-url (string->url (string-append "https://query.wikidata.org/sparql?query=" (uri-encode query)))
                  get-pure-port
                  port->string
                  header
                  ))

;; Get named values from a JSON record returned by a Wikidata SPARQL
;; query
(define (wikidata-values json fieldname)
  (map (lambda (wikidata_id)
         (hash-ref (hash-ref wikidata_id fieldname) 'value))
       (hash-ref (hash-ref json 'results) 'bindings))
  )

;; Get the wikidata_ids from a gene Name
(define/memoize (wikidata-ids gene-name)
  (display (sparql_wikidata_id gene-name))
  (let ([json (wikidata-json (sparql_wikidata_id gene-name))])
    (let ([values (wikidata-values json 'wikidata_id)])
      ; (display values)
      values
      )))

;; Get gene aliases for a wikidata_id
(define/memoize (wikidata-gene-aliases wikidata-id)
  (let ([aliases
         (wikidata-values (wikidata-json (sparql_gene_alias
                                          wikidata-id)) 'alias)])
    (filter-map (lambda (a) (and (not (string-contains? a " ")) a))
                aliases)))

;; Get gene aliases for a gene name (human, mouse and rat)
;; This function is called by "/gene/aliases/:name"
(define/memoize (gene-aliases gene-name)
  (let ([ids (wikidata-ids gene-name)])
     (flatten (map (lambda (id) (wikidata-gene-aliases id) )
         ids)))
  )

;; Get gene expanded aliases for a list of gene names (human, mouse
;; and rat) This function is called by "/gene/aliases/:names"
(define (gene-aliases2 gene-names)
  (map (lambda (gene-name)
         (list gene-name (gene-aliases gene-name)))
         gene-names)
  )
