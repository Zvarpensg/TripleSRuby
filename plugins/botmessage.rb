class BotMessage
  include Cinch::Plugin

  listen_to :mesg
  def listen(m, data)
    puts data
    args = data.split
    if args.size >= 2
      Channel(args[0]).send args[1,args.size].join(' ')
    end
  end
end
