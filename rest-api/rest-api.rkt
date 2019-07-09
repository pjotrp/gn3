#lang racket

;; This starts op the REST API server and lists the endpoints

(require (planet dmac/spin))
(require net/url)
(require "../../gn3/gn3/web/wikidata.rkt")

(get "/"
     (lambda () "[ \"Hello GeneNetwork3!\"  ]"))

(get "/gene/aliases/:name" (lambda (req)
                             (string-append "[\"" (params req 'name) "\"]")))

;; Starting the web server on port 8000
(display "Listening on port 8000:\n    curl http://localhost:8000/gene/aliases/BRCA2\n")
; (run)
