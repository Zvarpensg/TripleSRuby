class PokemonTip
	include Cinch::Plugin
	include Authentication
	match /pokemontip.*/i
	
	def execute(m)
		not_banned?(@bot, m) or return
		
		tips = IO.readlines(File.join(File.dirname(__FILE__), "tips.txt"))
		
		m.channel.send tips.sample
	end
end