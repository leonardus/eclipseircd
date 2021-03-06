Entity = require "entity"
numerics = require "numerics"

module = {}
module.activeChannels = {}

class Channel extends Entity
	new: (name) =>
		@name = name
		@topic = ""
		@topicFullhost = nil
		@topicTime = nil
		@users = {}
		@modeTypes = {
			"b": "A" -- ban
			"e": "A" -- exception
			"I": "A" -- invite-exception
			"k": "B" -- key
			"o": "B" -- operator
			"v": "B" -- voice
			"l": "C" -- client limit
			"i": "D" -- invite-only
			"m": "D" -- moderated
			"s": "D" -- secret
			"t": "D" -- protected topic
			"n": "D" -- no external messages
		}
		@modes = {
			-- channel modes
			"b": {} -- ban
			"e": {} -- exception
			"I": {} -- invite-exception
			"l": nil -- client limit
			"i": nil -- invite-only
			"k": nil -- key
			"m": nil -- moderated
			"s": nil -- secret
			"t": true -- protected topic
			"n": true -- no external messages
			
			-- channel membership prefixes
			"o": {} -- operator
			"v": {} -- voice
		}

	sendAll: (text) =>
		for _, channelUser in pairs @users do
			channelUser\send text

	removeUser: (user) =>
		-- remove the channel from the user's list of channels
		user.channels[@name] = nil

		-- remove the user from the channel's list of users
		for k, channelUser in pairs @users do
			if channelUser == user
				@users[k] = nil

		-- unset +v,+o
		@modes.v[user] = nil
		@modes.o[user] = nil

		-- delete the channel if it is empty
		if #@users < 1
			@destroy!
	
	destroy: =>
		module.activeChannels[@name] = nil

	sendTopic: (user) =>
		if @topic\len! == 0
			user\send numerics.RPL_NOTOPIC user, self
		else
			user\send numerics.RPL_TOPIC user, self
			user\send numerics.RPL_TOPICWHOTIME user, self

module.getChannel = (name) ->
	name = name\lower!
	-- create the channel if it does not exist
	isNewChannel = false
	unless module.activeChannels[name]
		module.activeChannels[name] = Channel name
		isNewChannel = true
	
	module.activeChannels[name], isNewChannel

module.channelExists = (name) ->
	for _, channel in pairs(module.activeChannels) do
		if channel.name\lower! == name\lower!
			return true
	return false

return module