require 'net/http'
require 'json'

class FrogTips
	include Cinch::Plugin
	include Authentication
	match /frogtip (.+)/i
	
	def execute(m, arg)
		not_banned(@bot, m) or return

		uri = 'http://frog.tips/api/1/tips/'

		if arg != ''
			uri += arg
		end

		resp = Net::HTTP.get_response(uri)
		if resp.code_type == Net::HTTPOK
			m.channel.send resp.body['tips'][0]['tip']
		else
			m.channel.send 'Error fetching frog tip. =('
		end
		
	end
end