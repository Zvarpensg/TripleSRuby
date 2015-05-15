require 'uri'

class FuckYeah
	include Cinch::Plugin
	include Authentication

	match /^fuck yeah (.+)/i, use_prefix: false

	def execute(m, arg)
		not_banned?(@bot, m) or return

		m.reply "http://fuckyeah.herokuapp.com/#{URI.escape(arg)}"
	end
end
