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

;; Get aliases for a gene name (can be Human, Rat, Mouse)
(get "/gene/aliases/:name"
     (lambda (req)
       (jsexpr->string (gene-aliases (params req 'name)))))

;; Start up web server

(display "Listening on port 8000:\n    curl http://localhost:8000/gene/aliases/BRCA2\n")
(run)
