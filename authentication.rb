
#TODO: persist data with sqlite, add permissions
module Authentication
  def is_op_with_auth(bot, m)
    if !m.user.authed?
      m.channel.send "You must be authed with NickServ to do this."
      return false
    end
    if !bot.config.ops.include? m.user.nick
      m.channel.send "You must be an op to do this."
      return false
    end

    return true
  end

  def is_op(bot, m)
    if !bot.config.ops.include? m.user.nick
      m.channel.send "You must be an op to do this."
      return false
    end

    return true
  end
end
