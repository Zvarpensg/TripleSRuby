class BotMessage
  include Cinch::Plugin

  listen_to :mesg
  def listen(m, data)
    puts data
    args = data.split
    if args.size >= 2
      puts args[0]
      Channel(args[0]).send "Message #{args[-1,1].join(' ')}"
    end
  end
end
