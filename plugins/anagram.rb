require 'net/http'
require 'uri'
require 'json'

class Anagram
	include Cinch::Plugin
	include Authentication
	match /anagram (.+)/i

	def execute(m, arg)
		not_banned?(@bot, m) or return

		response = Net::HTTP.post_form(
			URI.parse('http://www.sternestmeanings.com/say.json'), 'msg' => arg)
		j = JSON.parse(response.body)
		if j.class == Array
			m.channel.send "No anagram for you"
		else
			m.channel.send "\"#{arg}\" => \"#{j['message']['response']}\""
		end
	end
end
		
