class Test
  include Cinch::Plugin
  include Authentication

  match /test ?(.*)/, method: :test

  def test(m, args)
    require_groups(@bot, m, m.user.nick, ["TEST"]) or return

    m.channel.send "TEST!"
  end
end
