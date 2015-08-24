
class Decide
	include Cinch::Plugin
	include Authentication
	
	match /decide (.+)/, method: :decide
	
	def decide(m, args)
		not_banned?(@bot, m) or return
		
		if args.include? ","
			args = args.split ","
		elsif args.include? " "
			args = args.split " "
		end
		
		gen = Random.new
		m.channel.send "#{m.user.nick}: #{args[gen.rand(args.size)].strip}"
	end
end
