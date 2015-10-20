# Description
#   Sends messages to tree_planter
#
# Configuration:
#   HUBOT_TREE_REPO_PREFIX - git@code.example.com:user
#   HUBOT_TREE_DST_HOST    - drhost.example.com
#   HUBOT_TREE_PORT        - 4080
#
# Commands:
#   hubot plant <tree name> - <tree name> is the name of the code tree to deploy
#
# Author:
#   genebean

server = process.env.HUBOT_TREE_REPO_PREFIX
dst    = process.env.HUBOT_TREE_DST_HOST
port   = process.env.HUBOT_TREE_PORT ||= 4080


module.exports = (robot) ->
  robot.respond /plant (\w+)/i, (msg) ->
    tree = msg.match[1]
    repo = "#{server}/#{tree}.git"
    url  = "http://#{dst}:#{port}/deploy"
    data = JSON.stringify({
      tree_name: tree,
      repo_url: repo
    })

    msg.send "Planting #{tree} on #{dst}..."
    msg.http(url)
    .header('Content-Type', 'application/json')
    .post(data) (err, res, body) ->
      if err
        res.send "Encountered an error :( #{err}"
        return

      if res.statusCode isnt 200
        res.send "Request didn't come back HTTP 200 :("
        return

      msg.send body
