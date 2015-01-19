dns = require('dns')
_ = require('underscore')
fs = require('fs');

module.exports =
    results: []
    domains: []

    check: (domain, callback) ->
        if domain
            dns.resolve domain.domain, 'A', (err, addresses) =>
                if err
                    message = err.code + ', expected: ' + domain.ip
                    hosted = "negative"

                    @results.push
                        domain: domain.domain
                        hosted: hosted
                        message: message
                        ip: domain.ip
                        found: err.code

                    @check @domains.shift(), callback

                    return
                else
                    if _.indexOf(addresses, domain.ip) != -1
                        message = "Hosted by us."
                        hosted = "positive"

                        @results.push
                            domain: domain.domain
                            hosted: hosted
                            message: message
                            ip: domain.ip
                            found: addresses[0]

                        @check @domains.shift(), callback

                        return
                    else
                        dns.resolve domain.domain, 'NS', (err, nameservers) =>
                            if nameservers
                                for ns in nameservers
                                    if ns.indexOf "websitewelcome" == -1
                                        message = "Not hosted by us, found: " + addresses[0] + ", expected: " + domain.ip
                                        hosted = "negative"
                                    else
                                        message = "Possibly hosted by us, using our nameservers. Found: " + addresses[0] + ", expected: " + domain.ip
                                        hosted = "possible"
                            else
                                message = "Not hosted by us, found: " + addresses[0] + ", expected: " + domain.ip
                                hosted = "negative"


                            @results.push
                                domain: domain.domain
                                hosted: hosted
                                message: message
                                ip: domain.ip
                                found: addresses[0]
                                nameservers: nameservers

                            @check @domains.shift(), callback
        else
            callback(@results)

    run: (domains, callback) ->
        @domains = domains

        @check @domains.shift(), callback

    log: (groups) ->
        if groups.positive
            fs.writeFile "./logs/hosting-hosted.log", '', (err) ->
                if err
                    console.log err
                else
                    for positive in groups.positive
                        info =  """
                                #{positive.domain} is hosted by us.
                                    Found #{positive.found}
                                    Expected #{positive.ip}

                                """
                        fs.appendFile "./logs/hosting-hosted.log", info, (err) ->
                            if err
                                console.log err

        if groups.negative
            fs.writeFile "./logs/hosting-not_hosted.log", '', (err) ->
                if err
                    console.log err
                else
                    for negative in groups.negative
                        info =  """
                                #{negative.domain} is not hosted by us.
                                    Found #{negative.found}
                                    Expected #{negative.ip}

                                """
                        fs.appendFile "./logs/hosting-not_hosted.log", info, (err) ->
                            if err
                                console.log err

        if groups.possible
            fs.writeFile "./logs/hosting-possible.log", '', (err) ->
                if err
                    console.log err
                else
                    for possible in groups.possible
                        info =  """
                                #{possible.domain} possibly hosted by us.
                                    Found #{possible.found}
                                    Expected #{possible.ip}
                                    Nameservers #{possible.nameservers}

                                """
                        fs.appendFile "./logs/hosting-possible.log", info, (err) ->
                            if err
                                console.log err


