class RemindMe
	include Cinch::Plugin
	include Authentication

	match /remindme (.+)/, method: :addReminder

	def initialize(bot)
		super(bot);
		@timer = nil
		@activeReminders = {}
		resp = bot.config.database.execute "select nick,channel,reminder,reminderdate from reminders"
		resp.each do |reminder|
			addNewReminder(reminder[0], reminder[1], Reminder.new(reminder[2], Time.parse(reminder[3])))
		end
		info("Reminders loaded.")
	end

	# returns Time if humanDate is valid or nil if not
	def humanDatetoTime(humanDate)
		validwords = ["second", "minute", "hour", "day", "week", "month", "year"]

		groups = humanDate.scan(/([\d\.]+ [a-zA-Z]+)+/)
		!groups.nil? or return nil


		times = Hash[groups.map { |group| group[0].split(" ").reverse! }.map {|unit, num| [unit.end_with?("s") ? unit[0..unit.length-2] : unit, num] }]
		if times.keys.any? {|unit| !validwords.include? unit }
			return nil
		end
		
		carry = 0

		# for each unit starting with year, carry the decimal portion if it has one
		validwords.reverse.each do |unit|
			num = times.fetch(unit, 0).to_s
			if !(num.include? ".")
				times[unit] = Integer(num) + carry
			else
				thisunit, nextunit = num.split(".")
				times[unit] = Integer(thisunit) + carry
				carry = Integer(nextunit)
			end
		end
		# the last carry is ignored because why handle fractions of a second
		
		return formatTime(times.fetch("year", 0), times.fetch("month", 0), times.fetch("day", 0), times.fetch("hour", 0), times.fetch("minute", 0), times.fetch("second", 0))
	end
	
	def formatTime(year, month, day, hour, minute, second)
		# yes, this is ridiculous. no, there's not a better way.
		finalTime = DateTime.now
		finalTime = finalTime >> (year * 12 + month)
		finalTime = finalTime + day
		finalTime = finalTime.to_time
		finalTime = finalTime + hour * 60 * 60 + minute * 60 + second
		return finalTime
	end

	def addReminder(m, args)
		input = args.scan(/(?:in )?(.+?) to (.+)/)
		if input.empty?
			m.channel.send "Usage: remindme in <x> to <y>"
			return
		end

		currentTime = Time.now
		futureDate = humanDatetoTime(input[0][0])
		if futureDate.nil?
			begin
				futureDate = DateTime.parse(input[0][0]).to_time
			rescue ArgumentError
				m.channel.send("#{input[0]} is not a valid time.")
				return
			end
		end

		if (futureDate < currentTime)
			m.channel.send("I don't have a time machine.")
		else
			m.channel.send("Okay, will remind you #{args.include?("in ")? "" : "in "}#{args}")
			unsentReminder = Reminder.new(input[0][1], futureDate)
			addNewReminder(m.user.nick, m.channel.name, unsentReminder)
			@bot.config.database.execute(
				"insert into reminders (nick, channel, reminder, reminderdate) values (?, ?, ?, ?)",
				[m.user.nick, m.channel.name, unsentReminder.message, unsentReminder.date.to_s]
			)
		end
	end

	def sendReminder(user, channel, reminder)
		Cinch::Channel.new(channel, @bot).send("#{user}: #{reminder.message}")
		@bot.config.database.execute("delete from reminders where nick=? and channel=? and reminder=? and reminderdate=? limit 1",
			[user, channel, reminder.message, reminder.date.to_s])
	end

	def addNewReminder(user, channel, reminder)
		currentTime = Time.now

		@activeReminders[user] = reminder
		numSeconds = reminder.date.to_i - currentTime.to_i
		timer = Cinch::Timer.new(@bot, :interval => numSeconds > 0 ? numSeconds : 0, :shots => 1) { sendReminder(user, channel, reminder) }
		timer.start
	end

	class Reminder
		attr_reader :message, :date
		def initialize(reminder, date)
			@message = reminder
			@date = date
		end
	end

end