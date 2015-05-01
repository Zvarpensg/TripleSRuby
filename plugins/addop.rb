
class AddOp
  include Cinch::Plugin
  include Authentication

  match /addop (.+)/, method: :addop
  match /removeop (.+)/, method: :removeop
  match /listops/, method: :listops

  def addop(m, arg)
    is_op_with_auth(@bot, m) or return

    arg.split.each do |user|
      @bot.config.ops.push(user)
      puts @bot.config.ops
      m.channel.send "#{user} has been added."
    end
  end

  def removeop(m, arg)
    is_op_with_auth(@bot, m) or return

    arg.split.each do |user|
      if user == "connoor"
        m.channel.send "I can't delete connoor! That would be rude."
        next
      end
      if @bot.config.ops.delete(user) != nil
        m.channel.send "#{user} has been deleted."
      else
        m.channel.send "#{user} doesn't exist."
      end
    end
  end

  def listops(m)
    m.channel.send @bot.config.ops.join ", "
  end
end
