# Description
#   Allows you to run r10k commands on your Puppet Master
#
# Configuration:
#   HUBOT_PUPPET_SERVER
#
# Commands:
#   hubot r10k display - shows what r10k is managing
#   hubot run r10k - deploys all environments
#   hubot r10k env some_environment - deploys an individual environment
#   hubot r10k module some_module - deploys an individual module
#
# Notes:
#   This requires ssh keys to be setup. r10k is executed via sudo
#   so you will also need to let the account that hubot runs as
#   have passwordless sudo for the r10k command.
#
# Author:
#   genebean

exec   = require('child_process').exec
server = process.env.HUBOT_PUPPET_SERVER
r10k   = "ssh #{server} sudo r10k deploy"

module.exports = (robot) ->
  robot.respond /r10k display/i, (msg) ->
    cmd = "#{r10k} display -v error"

    msg.send "Getting what's managed by r10k on #{server}..."
    exec cmd, (error, stdout, stderr) ->
      msg.send error
      msg.send stdout
      msg.send stderr

  robot.respond /run r10k/i, (msg) ->
    cmd = "#{r10k} environment --puppetfile -v error"

    msg.send "Deploying all environments on #{server}..."
    exec cmd, (error, stdout, stderr) ->
      msg.send error
      msg.send stdout
      msg.send stderr

  robot.respond /r10k env (.+)/i, (msg) ->
    environment = msg.match[1]
    cmd         = "#{r10k} environment #{environment} --puppetfile -v error"

    msg.send "Deploying #{environment} on #{server}..."
    exec cmd, (error, stdout, stderr) ->
      msg.send error
      msg.send stdout
      msg.send stderr

  robot.respond /r10k module (\w+)/i, (msg) ->
    module = msg.match[1]
    cmd    = "#{r10k} module #{module} -v error"

    msg.send "Deploying #{module} on #{server}..."
    exec cmd, (error, stdout, stderr) ->
      msg.send error
      msg.send stdout
      msg.send stderr
