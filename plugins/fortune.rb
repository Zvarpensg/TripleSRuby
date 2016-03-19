
class Fortune
	include Cinch::Plugin
	include Authentication

	match "fortune"

	def execute(m)
		not_banned(@bot, m) or return

		m.reply `fortune`
	end
end
