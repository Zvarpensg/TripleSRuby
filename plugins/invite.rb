class Invite
	include Cinch::Plugin
	include Authentication
	
	match /join (.+)/, method: :join
	match /part (.+)/, method: :part
	
	listen_to :catchall
	
	def join(m, args)
		admin_and_not_banned(@bot, m) or return
		Channel(args).join
	end

	def part(m, args)
		admin_and_not_banned(@bot, m) or return
		Channel(args).part
	end
	
	def listen(m)
		if m.raw.include? "INVITE"
			m.channel.join
		end
	end
end
