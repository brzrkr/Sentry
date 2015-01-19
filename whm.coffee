cpanel = require("cpanel-lib")
CSON = require('cson')
_ = require('underscore')
clone = require('clone')

base_options =
  port: 2087
  secure: true
  ignoreCertError: true

module.exports =
  domains: []
  whm: []
  bw: []

  init: (filename) ->
    @whm = CSON.parseFileSync(filename)

  retrieveAccts: (account, callback) ->
    options = {}

    if(account)
      _.extend options, base_options, account

      cpanelClient = cpanel.createClient(options)
      cpanelClient.call "listaccts", {}, (err, res) =>
        for acct in res.acct
          @domains.push
            ip: acct.ip
            domain: acct.domain
            diskused: acct.diskused
            disklimit: acct.disklimit
            suspended: acct.suspended

        @retrieveAccts @whmList.shift(), callback

    else
      callback(@domains)

  retrieveBandwidth: (account, callback) ->
    # options = {}

    # if(account)
    #   _.extend options, base_options, account

    #   cpanelClient = cpanel.createClient(options)
    #   cpanelClient.call "showbw", {user: "rgvapic"}, (err, res) =>
    #     console.log(res)
    #     # for acct in res.acct
    #     #   @bw.push
    #     #     domain: acct.domain
    #     #     usage: acct.totalbytes
    #     #     limit: acct.limit

    #     @retrieveBandwidth @whmList2.shift(), callback

    # else
    #   callback(@bw)


  runAcct: (callback) ->
    @whmList = clone(@whm)
    @retrieveAccts @whmList.shift(), callback


  runBw: (callback) ->
    @whmList2 = clone(@whm)
    @retrieveBandwidth @whmList2.shift(), callback


