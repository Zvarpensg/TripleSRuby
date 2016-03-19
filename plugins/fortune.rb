
class Fortune
	include Cinch::Plugin
	include Authentication

	match "fortune"

	def execute(m)
		not_banned?(@bot, m) or return

		fortune = `fortune`.gsub(/\t/, ' ')
		if fortune.lines.length > 4
			m.user.send fortune
		else
			m.reply fortune
		end
	end
end
