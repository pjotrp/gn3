#lang racket ; at-exp br

(require (planet dmac/spin))
(require net/url)

(display "Listening on port 8000:\n    curl http://localhost:8000/gene/aliases/BRCA2\n")
(run)
