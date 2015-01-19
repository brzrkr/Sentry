phantom = require 'phantom'
dns = require 'dns'
_ = require 'underscore'
fs = require 'fs'

module.exports =
    results: []
    domains: []

    check: (domain, callback) ->
        if domain
            phantom.create (ph) =>
                ph.createPage (page) =>
                    page.set 'Referer', 'http://google.com'
                    page.set 'settings.userAgent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.89 Safari/537.1'
                    page.set 'viewportSize',
                        width: 1280
                        height: 1280
                    , (result) ->
                        console.log "Viewport set to: " + result.width + "x" + result.height

                    page.open "http://" + domain.domain, (status) =>
                        page.evaluate () ->
                            document.body.bgColor = 'white'

                        console.log("Status " + domain.domain + ":  " + status)

                        if status == "success"
                            page.render './logs/shots/' + domain.domain + '.png', () =>
                                @check @domains.shift(), callback
                                ph.exit()
                        else
                            @check @domains.shift(), callback
                            ph.exit()
        else
            callback(@results)

    run: (domains, callback) ->
        @domains = domains

        @check @domains.shift(), callback

    log: (groups) ->

