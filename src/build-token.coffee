# Description:
#   Build token
#
# Dependencies:
#   redis-brain.coffee
#
# Configuration:
#   None
#
# Commands:
#   hubot create build token for <topic>
#   hubot give me the build token for <topic>
#   hubot who has the build token for <topic>
#   hubot list all build tokens
#   hubot release the build token for <topic>
#   hubot forget all build tokens
# 
# Author:
#   @malcyL @kiyanwang

module.exports = (robot) ->

  initial_tokens = {
    1: {project: "rl-app", held_by: "no one"},
    2: {project: "dc-app", held_by: "no one"}
  }

  username_mappings = {
    1: {hipchat: "RossSinger", github: "rsinger"},
    2: {hipchat: "RichardTattersall", github: "lordtatty"},
    3: {hipchat: "ChrisClarke", github: "robotrobot"},
    4: {hipchat: "AndrewBate", github: "astilla"},
    5: {hipchat: "TimHodson", github: "timhodson"},
    6: {hipchat: "MarkWallsgrove", github: "markwallsgrove"},
    7: {hipchat: "RichardGubby", github: "rgubby"}
  }

  robot.brain.on 'loaded', =>
    robot.logger.info "Loading build_tokens"
    robot.brain.data.build_tokens ?= {}
    robot.brain.data.build_tokens = initial_tokens if Object.keys(robot.brain.data.build_tokens).length == 0

  ownerOfBuildToken = (token_name) ->
    for key, item of robot.brain.data.build_tokens
      if token_name == item.project
        found = true ; break
    if found == true
      @.key = key ; @.item = item
      return @
    else
      return null

  githubToHipchatName = (github_name) ->
    for key, item of username_mappings
      if github_name == item.github
        found = true ; break
    if found == true
      return item.hipchat
    else
      return github_name

  robot.hear /list (all )?build tokens/i, (msg) ->
    token_name = msg.match[2]
    if Object.keys(robot.brain.data.build_tokens) == 0
      msg.send "There are no build tokens."
    else
      for key, item of robot.brain.data.build_tokens
        msg.send "  #{item.project} : #{item.held_by}"

  robot.hear /who has (the )?build token (for )?(.*)/i, (msg) ->
    token_name = msg.match[3]
    if token_name is undefined
      msg.send "Which build token did you mean?"
    else
      result = new ownerOfBuildToken(token_name)
      if result.key?
        msg.send "#{result.item.held_by} has the build token for #{token_name}"
      else
        msg.send "I don't know anything about #{token_name}"

  robot.hear /give (me )?(the )?build token (for )?(.*)/i, (msg) ->
    token_name = msg.match[4]
    if token_name is undefined
      msg.send "Which build token did you mean?"
    else
      result = new ownerOfBuildToken(token_name)
      if result.key?
        if result.item.held_by == "no one"
          update = {project: "#{token_name}", held_by: "#{msg.message.user.mention_name}"}
          robot.brain.data.build_tokens[result.key] = update
          msg.send "You have the build token for #{token_name}!"
        else        
          msg.send "#{result.item.held_by} already has the build token for #{token_name}"
      else
        msg.send "I don't know anything about #{token_name}"

  robot.hear /release (the )?build token (for )?(.*)/i, (msg) ->
    token_name = msg.match[3]
    if token_name is undefined
      msg.send "Which build token did you mean?"
    else
      result = new ownerOfBuildToken(token_name)
      if result.key?
        if result.item.held_by == msg.message.user.mention_name
          update = {project: "#{token_name}", held_by: "no one"}
          robot.brain.data.build_tokens[result.key] = update
          msg.send "You have released the build token for #{token_name}!"
        else        
          msg.send "#{result.item.held_by} holds the token for #{token_name} - not you!"
      else
        msg.send "I don't know anything about #{token_name}"

  robot.hear /create build token (for )?(.*)/i, (msg) ->
    token_name = msg.match[2]
    if token_name is undefined
      msg.send "Which build token did you mean?"
    else
      result = new ownerOfBuildToken(token_name)
      if result.key?
        msg.send "Build token #{token_name} already exists."
      else
        next_id = Object.keys(robot.brain.data.build_tokens).length+1
        new_project = {project: "#{token_name}", held_by: "no one"}
        robot.brain.data.build_tokens[next_id] = new_project
        msg.send "You have created a build token for #{token_name}!"

  robot.hear /forget (all )?build tokens$/i, (msg) ->
    robot.brain.data.build_tokens = {}
    msg.send "OK, I've removed all build tokens."

  robot.hear /(.*) pushed to branch master of talis\/(.*)/i, (msg) ->
    pusher_name = msg.match[1]
    token_name = msg.match[2]
    result = new ownerOfBuildToken(token_name)
    if result.key?
      token_owner = result.item.held_by
      output = "#{pusher_name} pushed to master of #{token_name} \n    Build token for #{token_name} held by #{token_owner}"
      if githubToHipchatName(pusher_name) != token_owner
        output = output + "\n    #{pusher_name} DID not have permission to push to master of #{token_name}.\n    You're heading the right way for a SMACKED BOTTOM!"
      msg.send output

