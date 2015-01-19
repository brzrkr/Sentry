_ = require('underscore')
fs = require('fs')
CSON = require('cson')

module.exports =
    results: []
    domains: []

    init: (filename) ->

    check: (domain, callback) ->
        if domain
            difference = (domain.disklimit.slice(0, -1) - domain.diskused.slice(0, -1))

            if difference <= 150
                message = domain.domain + " is running out of disk space. Only " + difference + "M remaining of " + domain.disklimit
                status = "hitting"
            else
                message = domain.domain + " is fine on disk space. " + difference + "M remaining of " + domain.disklimit
                status = "good"

            @results.push
                    domain: domain.domain
                    message: message
                    status: status
                    diskused: domain.diskused
                    disklimit: domain.disklimit
                    difference: difference

            @check @domains.shift(), callback
        else
            callback(@results)

    run: (domains, callback) ->
        @domains = domains

        @check @domains.shift(), callback

    log: (groups) ->
        if groups.hitting
            fs.writeFile "./logs/bandwidth-hitting.log", '', (err) ->
                if err
                    console.log err
                else
                    for hitting in groups.hitting
                        info =  """
                                #{hitting.domain} is hitting their limit.
                                    Disk Limit #{hitting.disklimit}
                                    Disk Used #{hitting.diskused}
                                    Space Left #{hitting.difference}

                                """
                        fs.appendFile "./logs/bandwidth-hitting.log", info, (err) ->
                            if err
                                console.log err

        if groups.good
            fs.writeFile "./logs/bandwidth-good.log", '', (err) ->
                if err
                    console.log err
                else
                    for good in groups.good
                        info =  """
                                #{good.domain} is doing good on their space.
                                    Disk Limit #{good.disklimit}
                                    Disk Used #{good.diskused}
                                    Space Left #{good.difference}

                                """
                        fs.appendFile "./logs/bandwidth-good.log", info, (err) ->
                            if err
                                console.log err
