require 'net/http'
require 'uri'
require 'json'

class FML
	include Cinch::Plugin
	include Authentication

	match "fml"

	def execute(m)
		not_banned?(@bot, m) or return
		
		response = Net::HTTP.get(URI.parse("http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=10&q=http://feeds.feedburner.com/fmylife"))
		fml_entries = JSON.parse(response)['responseData']['feed']['entries']
		m.reply fml_entries[Random.rand(fml_entries.length)]['content'].gsub(/<\/?[^>]+(>|$)/, '')
	end
end
