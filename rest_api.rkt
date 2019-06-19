#lang racket
(require (planet dmac/spin))

(require net/url)

(get "/test"
     (lambda ()
       (call/input-url (string->url "https://www.ifixit.com/api/2.0/guides/13470")
                       get-pure-port port->string)
     ))

(get "/"
     (lambda () "Hello!"))

(get "/gene/aliases/:name" (lambda (req)
                             (string-append "[\"" (params req 'name) "\"]")))

(run)
