class Music
	include Cinch::Plugin
	include Authentication
	
	match /addmusic (.+)/, method: :addmusic
	match /music/, method: :getmusic
	
	def addmusic(m, arg)
		not_banned?(@bot, m) or return
		
		@bot.config.database.execute "insert into music (channel, link) values (?, ?)", [m.channel.name, arg]
	end
	
	def getmusic(m)
		numRows = @bot.config.database.execute("select COUNT(*) from music")[0][0]
		id = rand(numRows) + 1
		link = @bot.config.database.execute "select link from music where id=? and channel=?", [id, m.channel.name]
		puts "#{link.inspect} #{id}"
		if link.empty?
			m.channel.send "No music found :("
		else
			m.channel.send "#{m.user.nick}: #{link[0][0]}"
		end
	end
end