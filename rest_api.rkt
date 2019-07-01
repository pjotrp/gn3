#lang racket ; at-exp br

(require (planet dmac/spin))

(require net/url)

(get "/test"
     (lambda ()
       (call/input-url (string->url "https://www.ifixit.com/api/2.0/guides/13470")
                       get-pure-port port->string)
       ))


#|
List BRCA2:

SELECT ?b WHERE {wd:Q17853272 rdfs:label ?b . }

List BRCA2 from label

SELECT ?geneid ?p ?label
WHERE {
wd:Q17853272 rdfs:label ?label .
?geneid wdt:P31 wd:Q7187 .
?geneid rdfs:label ?label .
filter(?label="BRCA2"@en)
} limit 100

Find orthologs

  SELECT ?geneid ?s ?p
  WHERE {
    ?geneid wdt:P31 wd:Q7187 .
    ?s ps:P684 ?geneid
  } LIMIT 100


SELECT ?geneid ?label2
WHERE {
  SELECT ?geneid ?label2
  WHERE {
    ?geneid wdt:P31 wd:Q7187 .
     ?s ps:P702 ?geneid
    {
       select ?label where {
       ?geneid rdfs:label ?label .
       } limit 100
    }
    ?geneid rdfs:label ?label2 .
    filter (?label2 = "BRCA1"@en) .
  } limit 100
  # filter (?label2 == "BRCA1"@en) .
}

Finds the gene but is slow

  SELECT ?geneid ?label
  WHERE {
    ?geneid wdt:P31 wd:Q7187 .
    ?s ps:P702 ?geneid .
    ?geneid rdfs:label ?label .
    filter (?label = "BRCA1"@en) .
  } limit 100


  SELECT ?geneid ?label
  WHERE {
    ?geneid wdt:P31 wd:Q7187 .
    ?s ps:P702 ?geneid .
    {
      select ?label
      where {
        ?geneid rdfs:label ?label .
        filter (?label = "BRCA1"@en) .
      } limit 10
    }
    # filter (contains(?label,"BRCA1"@en)) .
  } limit 100


  SELECT DISTINCT ?geneid ?label
  WHERE {
    {
      select DISTINCT ?geneid ?label
      where {
        hint:Query hint:optimizer "None" .
        ?geneid wdt:P31 wd:Q7187 .
        ?s ps:P702 ?geneid .
        ?geneid rdfs:label ?label .
        FILTER (langMatches( lang(?label), "EN" ) )
      }
    }
    # filter (contains(?label,"BRCA2"@en)) .
    filter (?label = "BRCA2"@en) .

  } limit 100

This fetches all 900K en entries in 30 seconds (not too bad!)

  SELECT DISTINCT ?geneid ?label
  WHERE {
        hint:Query hint:optimizer "None" .
        ?geneid wdt:P31 wd:Q7187 .
        ?s ps:P702 ?geneid .
        ?geneid rdfs:label ?label .
        FILTER (langMatches( lang(?label), "EN" ) )
      }

We can do that once a day. Any better idea?

This is 22s.

  SELECT DISTINCT ?geneid ?label
  WHERE {
        # hint:Query hint:optimizer "None" .
        ?geneid wdt:P31 wd:Q7187 .
        ?s ps:P702 ?geneid .
        ?geneid rdfs:label ?label .
        FILTER (langMatches( lang(?label), "EN" ) && ?label = "BRCA2"@en)
      }

This one is instant

  SELECT DISTINCT ?geneid ?label
  WHERE {
        # hint:Query hint:optimizer "None" .
        ?geneid wdt:P31 wd:Q7187 .
        ?s ps:P702 ?geneid .
        ?geneid rdfs:label "BRCA1"@en .
        # FILTER (langMatches( lang(?label), "EN" ) && ?label = "BRCA2"@en)
      }


SELECT ?geneLabel (GROUP_CONCAT(DISTINCT ?geneAltLabel; separator="; ") AS ?geneAltLabel)
WHERE
{
    # https://www.wikidata.org/wiki/Q18247422 is Add1 in mouse
    wd:Q18247422 rdfs:label ?geneLabel ;
                 skos:altLabel ?geneAltLabel .

    FILTER(LANG(?geneLabel) = "en" &&
           LANG(?geneAltLabel) = "en").
}
GROUP BY ?geneLabel

Simpler version



SELECT DISTINCT ?name ?alias
WHERE
{
    <http://www.wikidata.org/entity/Q17853272> rdfs:label ?name ;
                                               skos:altLabel ?alias .

   FILTER(LANG(?name) = "en" && LANG(?alias) = "en").
}


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
       (call/input-url (string->url "https://query.wikidata.org/sparql?query=SELECT %3FhomologeneID%0AWHERE%0A{%0A%20%20%20 %23 wd%3AQ18247422 corresponds to Add1 in house mouse%0A%20%20%20 wd%3AQ18247422 wdt%3AP593 %3FhomologeneID .%0A%20%20%20%20%0A%2019%20%20 %23 an entire URI can be used%2C if it's wrapped in <>%0A%20%20%20 %23 <http%3A%2F%2Fwww.wikidata.org%2Fentity%2FQ29723729> wdt%3AP593 %3FhomologeneID%0A}%0A%0A")
                       get-pure-port port->string)
     ))

(get "/"
     (lambda () "[ \"Hello GeneNetwork3!\"  ]"))

(get "/gene/aliases/:name" (lambda (req)
                             (string-append "[\"" (params req 'name) "\"]")))


(display "Listening on port 8000:\n    curl http://localhost:8000/gene/aliases/BRCA2\n")
(run)
