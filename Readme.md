# Trail Watcher

records visitor paths into mongodb so we can query them and see what our visitors did.

 - a/b/c analysis via tags
 - funnel analysis based on visited paths

### Start or continue visit tracking
    <img src="http://localhost:3000/track?...&start=1" />

### Continue visit tracking
    <img src="http://localhost:3000/track?path=#{CGI.escape(request.request_uri)}&referrer=#{CGI.escape(equest.referrer)}" />

### Set tags
Mark the visitor as registered user coming from facebook.

    <img src="http://localhost:3000/track?...&tags=registered,via-facebook" />

### Analyse

    /analyse

### Setup development server

    git clone git@github.com:dawanda/trail_watcher.git
    cd trail_watcher
    bundle
    cp config/config.example.yml config/config.yml
    cp config/mongoid.example.yml config/mongoid.yml
    # start mongo
    rake spec


### Copy production db to local

    db.copyDatabase('trail_watcher_production', 'trail_watcher_development', HOST-IP [, username[, password]])

Deploy
======

 - add servers to config.yml
 - prepare server dirs
 - `cap production deploy:cold`
 - add configs to /srv/#{target}/shared/config/
 - deploy as usual

TODO
====
Set dynamic ttl

    <img src="http://localhost:3000/track?...&ttl=1h" />

[Orgcharts](http://code.google.com/apis/chart/interactive/docs/gallery/orgchart.html) for path analysis
