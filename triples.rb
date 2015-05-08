#!/usr/bin/ruby
# encoding: utf-8
require 'cinch'
require 'json'
require_relative 'irclistener'

# require all plugins in plugins/
Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each {|file| require file }

bot = Cinch::Bot.new do
	if(File.exists?("./bot.json")) then
		botJSON = ""
		File.open("./bot.json") do |file|
			botJSON = JSON.parse file.read
		end

		configure do |c|
			c.nick = botJSON["nick"]
			c.server = botJSON["server"]
			c.channels = botJSON["channels"]

			c.password = botJSON["password"]
			c.port = botJSON["port"]
			c.ssl.use = botJSON["ssl"]
			c.listenPort = botJSON["listenport"]
			c.listenAddress = botJSON["listenaddress"]

			c.plugins.plugins = [Hello, FuckYeah, FML, CatFact, CatFace]
			c.plugins.prefix = /^(!|#{c.nick}(?:[,:]{1} | ))/
		end
	else
		abort("Need a 'bot.json' config file to start. Exiting...")
	end
end
Thread.abort_on_exception=true
Thread.new { IRCListener.new(bot).start }
bot.start
