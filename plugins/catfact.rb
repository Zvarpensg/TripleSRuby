require 'net/http'
require 'uri'
require 'json'

class CatFact
	include Cinch::Plugin

	match "catfact"

	def execute(m)
		response = Net::HTTP.get(URI.parse("http://catfacts-api.appspot.com/api/facts"))
		m.reply JSON.parse(response)['facts'][0]
	end
end