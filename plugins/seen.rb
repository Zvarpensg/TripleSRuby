class Seen
	include Cinch::Plugin
	include Authentication

	listen_to :message
	match /seen ([^ ]+)$/


	def execute(m, arg)
		not_banned(@bot, m) or return
		resp = @bot.config.database.execute "select lasttext,seendate from seen where nick=? and channel=?", [arg, m.channel.name]
		if resp.empty?
			m.channel.send "I've never seen #{arg}"
		else
			m.channel.send "#{arg} was last seen at #{resp[0][1]} saying #{resp[0][0]}"
		end
	end

	def listen(args)
		@bot.config.database.execute "insert or replace into seen (nick, channel, lasttext, seendate) values (?, ?, ?, ?)", [args.user.nick, args.channel.name, args.params[1], DateTime.now.to_s]
	end

end