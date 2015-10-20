# Description
#   Query PuppetDB for a host or resource
#
# Configuration:
#   HUBOT_PUPPETDB_SERVER - your puppetdb server
#   HUBOT_PUPPETDB_PORT   - the port you query on
#   HUBOT_PUPPETDB_CA     - the cert to auth with
#   HUBOT_PUPPETDB_CERT   - the path where the certs are stored
#   HUBOT_PUPPETDB_KEY    - the path where the key is stored
#
# Commands:
#   when did <node name> last report - shows the last report time using local time
#   what nodes (use|have) <resource type> <resource title> - shows a sorted list of nodes with the resource
#   how many nodes (use|have) <resource type> <resource title> - shows a count of the nodes using the resource
#
# Author:
#   genebean

exec   = require('child_process').exec
server = process.env.HUBOT_PUPPETDB_SERVER
port   = process.env.HUBOT_PUPPETDB_PORT ||= 8081
cert   = process.env.HUBOT_PUPPETDB_CERT
ca     = process.env.HUBOT_PUPPETDB_CA
key    = process.env.HUBOT_PUPPETDB_KEY
url    = "https://#{server}:#{port}"
buffer = 1024 * 1024
options =
  'maxBuffer': buffer

module.exports = (robot) ->
  robot.hear /when did ([\w\.-]+) last report(\?)?/i, (msg) ->
    host     = msg.match[1]
    endpoint = "v3/nodes"
    cmd      = "curl -s \"#{url}/#{endpoint}/#{host}\" --cacert #{ca} --cert #{cert} --key #{key} --tlsv1"

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

  robot.hear /what nodes (use|have) (\w+) ([\w\:]+)/i, (msg) ->
    type     = msg.match[2].charAt(0).toUpperCase() + msg.match[2].slice(1).toLowerCase()
    title_orig = msg.match[3].split "::"
    title      = ""
    for part in title_orig
      if title.length isnt 0
        title = title + "::"
      title = title + part.charAt(0).toUpperCase() + part.slice(1).toLowerCase()
    endpoint = "v3/resources"
    cmd      = "curl -s \"#{url}/#{endpoint}/#{type}/#{title}\" --cacert #{ca} --cert #{cert} --key #{key} --tlsv1"

    exec cmd, options, (error, stdout, stderr) ->
      if error
        msg.send error
        return

      if stderr
        msg.send stderr
        return

      data = JSON.parse(stdout)
      hosts = []
      for host in data
        hosts.push host.certname
      if hosts.length is 0
        msg.send "No nodes seem to #{msg.match[1]} #{type} #{title}"
      else
        hosts.sort()
        for host in hosts
          msg.send host

  robot.hear /how many nodes (use|have) (\w+) ([\w\:]+)/i, (msg) ->
    type       = msg.match[2].charAt(0).toUpperCase() + msg.match[2].slice(1).toLowerCase()
    title_orig = msg.match[3].split "::"
    title      = ""
    for part in title_orig
      if title.length isnt 0
        title = title + "::"
      title = title + part.charAt(0).toUpperCase() + part.slice(1).toLowerCase()
    endpoint   = "v3/resources"
    cmd        = "curl -s \"#{url}/#{endpoint}/#{type}/#{title}\" --cacert #{ca} --cert #{cert} --key #{key} --tlsv1"

    exec cmd, options, (error, stdout, stderr) ->
      if error
        msg.send error
        return

      if stderr
        msg.send stderr
        return

      data = JSON.parse(stdout)
      hosts = []
      for host in data
        hosts.push host.certname
      if hosts.length is 0
        msg.send "No nodes seem to #{msg.match[1]} #{type} #{title}"
      else
        msg.send "It looks like #{hosts.length} nodes #{msg.match[1]} #{type} #{title}"
