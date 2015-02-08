require 'cinch'
require 'json'

# require all plugins in plugins/
Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each {|file| require file }

bot = Cinch::Bot.new do
	if(File.exists?("./bot.json")) then
		file = File.open("./bot.json").read
		botJSON = JSON.parse file

		configure do |c|
			c.nick = botJSON["nick"]
			c.server = botJSON["server"]
			c.channels = botJSON["channels"]

			c.password = botJSON["password"]
			c.port = botJSON["port"]
			c.ssl.use = botJSON["ssl"]

			c.plugins.plugins = [Hello, FuckYeah, FML, CatFact]
			c.plugins.prefix = /^(!|#{c.nick}[,: ]*)/
		end
	else
		abort("Need a 'bot.json' config file to start. Exiting...")
	end
end

bot.start
