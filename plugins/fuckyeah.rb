require 'uri'

class FuckYeah
	include Cinch::Plugin

	match /^fuck yeah (.+)/i, use_prefix: false

	def execute(m, arg)
		m.reply "http://fuckyeah.herokuapp.com/#{URI.escape(arg)}"
	end
end