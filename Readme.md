# Trail Watcher

records visitor paths into mongodb so we can query them and see what our visitors did.

### Track visit:
    <img src="http://localhost:3000/track?path=#{CGI.escape(request.request_uri)}&referrer=#{CGI.escape(equest.referrer)}" />

### Set tags
Mark the visitor as registered user coming from facebook.

    <img src="http://localhost:3000/track?...&tags=registered,via-facebook" />

### Analyse

    /analyse

TODO
====
Set dynamic ttl

    <img src="http://localhost:3000/track?...&ttl=1h" />
