require 'cinch'

# require all plugins in plugins/
Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each {|file| require file }

bot = Cinch::Bot.new do	
	configure do |c|
		c.server = "irc.freenode.net"
		c.nick = "TripleS"
		c.channels = [""]

		c.plugins.plugins = [Hello, FuckYeah, FML]
		c.plugins.prefix = /^(!|#{c.nick}[,: ]*)/
	end
end

bot.start