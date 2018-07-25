users = require "users"
channels = require "channels"
numerics = require "numerics"
config = require "config"
parse = require "ircserverparse"

commands =
	"NICK": require "commands.NICK"
	"USER": require "commands.USER"
	"CAP": require "commands.CAP"
	"MODE": require "commands.MODE"
	"JOIN": require "commands.JOIN"
	"PART": require "commands.PART"
	"PRIVMSG": require "commands.PRIVMSG"
	"TOPIC": require "commands.TOPIC"
	"QUIT": require "commands.QUIT"
	"NAMES": require "commands.NAMES"
	"KICK": require "commands.KICK"

return (user, line) ->
	command = line.command or line.numeric
	command = command\upper!
	if commands[command]
		commands[command] line, user