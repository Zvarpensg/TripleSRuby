class Test
  include Cinch::Plugin
  include Authentication

  match /test ?(.*)/, method: :test

  def test(m, args)
    has_groups(bot, m, ["TEST"]) and no_groups(bot, m, ["BANNED"]) or return

    m.channel.send "TEST!"
  end
end
