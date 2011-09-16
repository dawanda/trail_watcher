# Trail Watcher

records visitor paths into mongodb so we can query them and see what our visitors did.

 - a/b/c analysis via tags
 - funnel analysis based on visited paths

### Example tracking pixel
    <img src="http://localhost:3000/track?path=/users/index&referrer=/product/show&tags=via_ad&start=1" />


### Start or continue visit tracking
    <img src="http://localhost:3000/track?...&start=1" />

### Continue visit tracking
    <img src="http://localhost:3000/track?path=#{CGI.escape(request.request_uri)}&referrer=#{CGI.escape(equest.referrer)}" />

### Set tags
Mark the visitor as registered user coming from facebook.

    <img src="http://localhost:3000/track?...&tags=registered,via-facebook" />

### Analyse

    /analyse

#### Funnel analyse chart
![Funnel analyse](http://cl.ly/0S3C14100U2F3v0P0S0J/trail_watcher_funnel_analyse.png)

#### Org chart "going to"
![org chart going_to](http://cl.ly/0J22182F2n3s0C2h2z1i/trail_watcher_org_chart_going_to.png)

#### Org chart "coming from"
![org chart coming_from](http://cl.ly/301u2F0K0U3r0N0U3j3X/trail_watcher_org_chart_coming_from.png)

### Setup development server

    git clone git@github.com:dawanda/trail_watcher.git
    cd trail_watcher
    bundle
    cp config/config.example.yml config/config.yml
    cp config/mongoid.example.yml config/mongoid.yml
    # start mongo
    rake spec
    rails s


### Copy production db to local

    > mongo

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
