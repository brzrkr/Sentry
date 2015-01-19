fs = require("fs")
utils = require("utils")
casper = require('casper').create()

casper.start casper.cli.get(0), () ->
  @echo @getTitle()

casper.run()