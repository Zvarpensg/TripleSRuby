class Hello
	include Cinch::Plugin

	match /^hello/i, use_prefix: false

	def execute(m)
		m.reply "Hello, #{m.user.nick}"
	end
end