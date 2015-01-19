hosted = require('./tests/hosted-by-us')
disk = require('./tests/disk-checker')
whm = require('./whm')
argv = require('yargs').argv
_ = require('underscore')
clone = require('clone')
shots = require('./tests/grab-screen')

run = () ->
    if(argv.whm)
        whm.init(argv.whm)

        whm.runAcct (domains) ->
            console.log "Found " + domains.length + " domains."

            if(argv.testHosting)
                hosted.run clone(domains), (results) ->
                    groups = _.groupBy(results, 'hosted')
                    console.log "Found " + groups.positive.length + " out of " + results.length + " hosted by us."  unless !groups.positive
                    console.log "Found " + groups.negative.length + " out of " + results.length + " not hosted by us."  unless !groups.negative
                    console.log "Found " + groups.possible.length + " out of " + results.length + " possibly hosted by us." unless !groups.possible
                    hosted.log groups

                    if(argv.testShots)
                        shots.run clone(groups.positive), (results) ->
                            console.log results

            if(argv.testDisk)
                disk.run clone(domains), (results) ->
                    groups = _.groupBy results, 'status'

                    console.log "Found " + groups.hitting.length + " out of " + results.length + " hitting their disk  limit."  unless !groups.hitting
                    console.log "Found " + groups.good.length + " out of " + results.length + " doing fine on their disk limit"  unless !groups.good

                    disk.log groups

    if(argv.testBandwidth)
        whm.runBw (domains) ->
            console.log domains




    if(argv.domains)
        console.log "Not implemented"

process.on 'exit', () ->
    console.log "Exiting..."

run()