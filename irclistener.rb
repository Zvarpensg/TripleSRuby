require 'eventmachine'

class Server < EventMachine::Connection
  attr_accessor :bot

  def receive_data(data)
    @bot.handlers.dispatch(:mesg, nil, data)
  end
end

class IRCListener
  def initialize(bot)
    @bot = bot
  end

  def start
    EM.run do
      EM.start_server @bot.config.listenAddress, @bot.config.listenPort, Server do |conn|
        conn.bot = @bot
      end
    end
  end
end
