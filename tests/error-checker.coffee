dns = require('dns')
_ = require('underscore')
fs = require('fs')
spider = require('spider')

module.exports =
    results: []
    domains: []

    check: (domain, callback) ->
        if domain
            @check @domains.shift(), callback
        else
            callback(@results)

    run: (domains, callback) ->
        @domains = domains

        @check @domains.shift(), callback

    log: (groups) ->
