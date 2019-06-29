#lang racket
(require (planet dmac/spin))

(require net/url)

(get "/test"
     (lambda ()
       (call/input-url (string->url "https://www.ifixit.com/api/2.0/guides/13470")
                       get-pure-port port->string)
       ))

#|
curl "http://localhost:8000/wikidata" returns
<?xml version='1.0' encoding='UTF-8'?>
<sparql xmlns='http://www.w3.org/2005/sparql-results#'>
        <head>
                <variable name='homologeneID'/>
        </head>
        <results>
                <result>
                        <binding name='homologeneID'>
                                <literal>22758</literal>
                        </binding>
                </result>
        </results>
</sparql>
|#

(get "/wikidata"
     (lambda ()
       (call/input-url (string->url "https://query.wikidata.org/sparql?query=SELECT %3FhomologeneID%0AWHERE%0A{%0A%20%20%20 %23 wd%3AQ18247422 corresponds to Add1 in house mouse%0A%20%20%20 wd%3AQ18247422 wdt%3AP593 %3FhomologeneID .%0A%20%20%20%20%0A%20%20%20 %23 an entire URI can be used%2C if it's wrapped in <>%0A%20%20%20 %23 <http%3A%2F%2Fwww.wikidata.org%2Fentity%2FQ29723729> wdt%3AP593 %3FhomologeneID%0A}%0A%0A")
                       get-pure-port port->string)
     ))

(get "/"
     (lambda () "[ \"Hello GeneNetwork3!\"  ]"))

(get "/gene/aliases/:name" (lambda (req)
                             (string-append "[\"" (params req 'name) "\"]")))


(display "Listening on port 8000:\n    curl http://localhost:8000/gene/aliases/BRCA2\n")
(run)
