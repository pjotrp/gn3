#lang racket

;; This starts op the REST API server and lists the endpoints

(require (planet dmac/spin))
(require net/url)
(require json)
(require "../../gn3/gn3/web/wikidata.rkt")

(get "/"
     (lambda () "[ \"Hello GeneNetwork3!\"  ]"))

;; Internal request for wikidata ids belonging to a gene name (Shh,
;; BRCA2)
(get "/internal/wikidata/ids/:genename"
     (lambda (req)
       (jsexpr->string (wikidata-ids (params req 'genename)))))

;; Get aliases for a gene name (can be Human, Rat, Mouse).
(get "/gene/aliases/:name"
     (lambda (req)
       (jsexpr->string (gene-aliases (params req 'name)))))

;; Get expanded aliases for a comma separated list of gene names (can
;; be Human, Rat, Mouse).
(get "/gene/aliases2/:names"
     (lambda (req)
       (jsexpr->string (gene-aliases2 (string-split (params req 'names) ",")))))

;; Start up web server

(define port 8000)
(define port-str (number->string port))
(display (string-append "Listening on port " port-str ":\n    curl http://localhost:" port-str "/gene/aliases/BRCA2\n"))
(run #:port port)
