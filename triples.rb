#!/usr/bin/ruby
# encoding: utf-8
require 'rubygems'
require 'bundler/setup'
require 'cinch'
require 'json'
require_relative 'irclistener'
require_relative 'authentication'
require 'sqlite3'

# require all plugins in plugins/
Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each {|file| require file }

#nested plugins too
Dir[File.dirname(__FILE__) + '/plugins/*/*.rb'].each {|file| require file }

botJSON = ""
if(File.exists?("./bot.json")) then
	file = File.open("./bot.json").read
	botJSON = JSON.parse file
else
	abort("Need a 'bot.json' config file to start. Exiting...")
end

SQLite3::Database.new botJSON["database"] do |db|
	db.execute("PRAGMA foreign_keys = ON;") # disabled by default :(
	bot = Cinch::Bot.new do
		configure do |c|
			c.nick = botJSON["nick"]
			c.server = botJSON["server"]
			c.channels = botJSON["channels"]

			c.password = botJSON["password"]
			c.port = botJSON["port"]
			c.ssl.use = botJSON["ssl"]
			c.listenPort = botJSON["listenport"]
			c.listenAddress = botJSON["listenaddress"]
			c.database = db

			# The owner can't be removed or banned for security purposes
			c.owner = botJSON["owner"]

			# Update database with owner. if the user was added previously with lower
			# permissions they will be updated accordingly

			db.execute "insert or ignore into users(nick) values (?)", c.owner
			db.execute "insert or ignore into groups(name) values ('ADMIN')"
			db.execute "insert or ignore into groups(name) values ('BANNED')"
			db.execute "insert or ignore into usergroups(user_id, group_id) values ("\
										"(select id from users where nick=?), "\
										"(select id from groups where name='ADMIN'))", c.owner

			c.plugins.plugins = botJSON["plugins"].map {|plugin| Object.const_get plugin }
			c.plugins.prefix = /^(?:!|#{Regexp.quote(c.nick)}(?:[,:]{1} | ))/
		end
	end

	Thread.abort_on_exception=true
	Thread.new { IRCListener.new(bot).start }
	bot.loggers.level = :info
	bot.start
end
