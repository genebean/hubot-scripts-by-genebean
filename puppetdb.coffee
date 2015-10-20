# Description
#   Query PuppetDB for a host
#
# Configuration:
#   HUBOT_PUPPETDB_SERVER - your puppetdb server
#   HUBOT_PUPPETDB_PORT   - the port you query on
#   HUBOT_PUPPETDB_CA     - the cert to auth with
#   HUBOT_PUPPETDB_CERT   - the path where the certs are stored
#   HUBOT_PUPPETDB_KEY    - the path where the key is stored
#
# Commands:
#   when did <node name> last report[?]
#
# Author:
#   genebean

exec   = require('child_process').exec
server = process.env.HUBOT_PUPPETDB_SERVER
port   = process.env.HUBOT_PUPPETDB_PORT ||= 8081
cert   = process.env.HUBOT_PUPPETDB_CERT
ca     = process.env.HUBOT_PUPPETDB_CA
key    = process.env.HUBOT_PUPPETDB_KEY

module.exports = (robot) ->
  robot.hear /when did ([\w\.-]+) last report(\?)?/i, (msg) ->
    host       = msg.match[1]
    url        = "https://#{server}:#{port}/v3/nodes"
    cmd = "curl -s \"#{url}/#{host}\" --cacert #{ca} --cert #{cert} --key #{key} --tlsv1"

    exec cmd, (error, stdout, stderr) ->
      if error
        msg.send error
        return

      if stderr
        msg.send stderr
        return

      data = JSON.parse(stdout)
      if data.hasOwnProperty('error')
        msg.send data.error
      else
        date = new Date(data.report_timestamp)
        msg.send "#{host} last reported at #{date.toLocaleString()}"
