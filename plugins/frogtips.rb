require 'net/http'
require 'json'

class FrogTips
	include Cinch::Plugin
	include Authentication

	def make_request(m, arg = '')
		url = "http://frog.tips/api/1/tips/#{arg}"
		resp = Net::HTTP.get_response(URI(url))
		if resp.code_type == Net::HTTPOK
			return JSON.parse(resp.body)
		else
			m.channel.send 'Error fetching tip. =('
			return nil
		end
	end

	match /frogtip\s*$/i, method: :random_tip
	def random_tip(m)
		not_banned?(@bot, m) or return

		resp = make_request(m)
		if resp != nil
			m.channel.send resp['tips'][0]['tip']
		end
	end

	match /frogtip ([0-9]+)/i, method: :specific_tip
	def specific_tip(m, tipno)
		not_banned?(@bot, m)

		resp = make_request(m, tipno)
		if resp != nil
			m.channel.send resp['tip']
		end
	end
end
