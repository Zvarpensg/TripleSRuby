class Hello
	include Cinch::Plugin
	include Authentication

	match /^hello/i, use_prefix: false

	def execute(m)
		not_banned?(@bot, m) or return

		m.reply "Hello, #{m.user.nick}"
	end
end
