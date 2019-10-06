#lang racket

(require "../../gn3/gn3/web/wikidata.rkt")

(require rackunit)

(test-case
 "Wikidata-tests"
 (writeln "Running Wikidata-tests...")
  (check-equal? (string-split "Shh" ",") '("Shh"))
  (check-equal? (string-split "Shh,Brca2" ",") '("Shh" "Brca2"))
  (writeln "HERE")
  (check-equal? (gene-aliases2 (string-split "Shh" ",")) ;; returns mouse and rat!
  '(("Shh" ("Hx" "ShhNC" "9530036O11Rik" "Dsh" "Hhg1" "Hxl3" "M100081" "ShhNC"))))
  (check-equal? (gene-aliases2 (string-split "Shh,Brca2" ",")) ;; returns mouse and rat!
                '(("Shh" ("Hx" "ShhNC" "9530036O11Rik" "Dsh" "Hhg1" "Hxl3" "M100081" "ShhNC"))
                  ("Brca2" ("Fancd1" "RAB163")))
 ))
