#lang racket

(require json)
(require "../../gn3/gn3/web/wikidata.rkt")

(require rackunit)

(test-case
 "Wikidata-tests"
 (check-equal? (wikidata-ids "Shh") '("http://www.wikidata.org/entity/Q14860079" "http://www.wikidata.org/entity/Q24420953"))
 (check-equal? (jsexpr->string (wikidata-ids "BRCA2"))  "[\"http://www.wikidata.org/entity/Q17853272\"]")
 )
