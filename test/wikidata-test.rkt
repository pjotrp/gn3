#lang racket

(require json)
(require "../../gn3/gn3/web/wikidata.rkt")

(require rackunit)

(test-case
 "Wikidata-tests"
 (check-equal? (wikidata-ids "Shh") '("http://www.wikidata.org/entity/Q14860079" "http://www.wikidata.org/entity/Q24420953"))
 (check-equal? (jsexpr->string (wikidata-ids "BRCA2"))  "[\"http://www.wikidata.org/entity/Q17853272\"]")
 (check-equal? (wikidata-gene-aliases "http://www.wikidata.org/entity/Q17853272")
               '("FACD"
                 "FAD"
                 "FANCD"
                 "BROVCA2"
                 "FAD1"
                 "FANCD1"
                 "BRCC2"
                 "GLM3"
                 "PNCA2"
                 "XRCC11")
               )
 (check-equal? (gene-aliases "BRCA2")
               '("FACD"
                 "FAD"
                 "FANCD"
                 "BROVCA2"
                 "FAD1"
                 "FANCD1"
                 "BRCC2"
                 "GLM3"
                 "PNCA2"
                 "XRCC11"))
 (check-equal? (gene-aliases "SHH")
               '("TPT" "HLP3" "HHG1" "HPE3" "MCOPCB5" "ShhNC" "SMMCI" "TPTPS"))
 )
