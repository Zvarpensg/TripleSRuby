class Permissions
  include Cinch::Plugin
  include Authentication

  match /adduser (.+)/, method: :adduser
  match /deleteuser (.+)/, method: :deleteuser
  match /addgroup (.+)/, method: :addgroup
  match /deletegroup (.+)/, method: :deletegroup
  match /moduser (.+)/, method: :moduser
  match /groups ?(.*)/, method: :groups
  match /pluginban (.+)/, method: :pluginban

  def adduser(m, arg)

    admin_and_not_banned(@bot, m) or return

    args = arg.split(" ")
    if args.length != 2
      m.channel.send("Usage: adduser NICK GROUP")
      return
    end

    if user_exists?(@bot, args[0])
      m.channel.send("User %s already exists, if you wish to modify the user use moduser." % args[0])
      return
    end

    # check group exists and obtain ID
    groupID = group_id(@bot, args[1])
    if groupID.nil?
      m.channel.send("No such group %s." % args[1])
      return
    end

    @bot.config.database.execute "insert into users(nick) values (?)", args[0]
    newUserID = @bot.config.database.last_insert_row_id()
    @bot.config.database.execute "insert into usergroups(user_id, group_id) values (?, ?)", [newUserID, groupID]
    m.channel.send("Added user %s." % args[0])
  end

  def deleteuser(m, arg)

    admin_and_not_banned(@bot, m) or return

    args = arg.split(" ")
    if args.length != 1
      m.channel.send "Usage: deleteuser NICK"
      return
    end

    userID = user_id(@bot, args[0])
    if userID.nil?
      m.channel.send("No such user %s." % args[0])
      return
    end

    if args[0] == @bot.config.owner
      m.channel.send "Can't delete the bot's owner."
      return
    end

    @bot.config.database.execute "delete from users where id=?", userID
    m.channel.send("User %s deleted." % args[0])
  end

  def addgroup(m, arg)

    admin_and_not_banned(@bot, m) or return

    args = arg.split(" ")
    if args.length != 1
      m.channel.send "Usage: addgroup GROUP"
      return
    end

    groupID = group_id(@bot, args[0])
    if !groupID.nil?
      m.channel.send("Group %s already exists." % args[0])
      return
    end

    if /^[^\+-]+$/.match(args[0]).nil?
      m.channel.send("Characters +,- are forbidden in group names.")
      return
    end

    @bot.config.database.execute "insert into groups(name) values (?)", args[0]
    m.channel.send "Added group %s." % args[0]
  end

  def deletegroup(m, arg)
    admin_and_not_banned(@bot, m) or return

    args = arg.split(" ")
    if args.length != 1
      m.channel.send "Usage: deletegroup GROUP"
      return
    end

    require_groups(@bot, m, m.user.nick, ["ADMIN"]) or return

    if args[0] == "ADMIN" # someone just has to try
      m.channel.send "That would be a really dumb thing to do."
      return
    end

    groupID = group_id(@bot, args[0])
    if groupID.nil?
      m.channel.send "No such group %s." % args[0]
      return
    end

    @bot.config.database.execute "delete from groups where name=?", args[0]
    m.channel.send "Group %s deleted." % args[0]
  end

  def moduser(m, arg)

    admin_and_not_banned(@bot, m) or return

    valid = /^(\+|-)(\w+) ?((\+|-)?\w+ ?)*$/ # a word preceded by a plus or minus followed by any number of words
                                             # with an optional plus or minus. I.E +ADMIN TEST -BANNED

    args = arg.split(" ")
    groups = args[1, args.length]
    match = valid.match groups.join(" ")
    puts match
    if args.length < 2 || match.nil?
      m.channel.send("Usage: USER (+|-)GROUPS")
      return
    end

    userID = user_id(@bot, args[0])
    if userID.nil?
      m.channel.send("User %s does not exist." % args[0])
    end

    currentOperator = ""
    missingGroups = []

    changesDone = false
    groups.each do |group|
      if ["-", "+"].include? group[0]
        currentOperator = group[0]
        group = group[1, group.length]
      end
      groupID = group_id(@bot, group)
      if currentOperator == "+"
        if groupID.nil?
          missingGroups.push group
          next
        end
        if group == "BANNED" && args[0] == @bot.config.owner
          m.channel.send "You can't ban the bot's owner."
          next
        end
        @bot.config.database.execute "insert or ignore into usergroups(user_id, group_id) values (?, ?)", [userID, groupID]
        changesDone = true
      elsif currentOperator == "-"
        if group == "ADMIN" && args[0] == @bot.config.owner
          m.channel.send "You can't remove the bots owner from ADMIN."
          next
        end
        @bot.config.database.execute "delete from usergroups where user_id=? and group_id=?", [userID, groupID]
        changesDone = true
      end
    end

    if missingGroups != []
      m.channel.send("The following groups do not exists: %s" % missingGroups.join(", "))
    end

    if changesDone
      m.channel.send("User %s modified." % args[0])
    end
  end

  def groups(m, arg)
    no_groups(bot, m, ["BANNED"]) or return

    groups = []
    if arg == ""
      groups = get_groups(bot, m.user.nick)
    else
      has_groups(bot, m, ["ADMIN"]) or return
      args = arg.split(" ")
      if args.length != 1
        m.channel.send "Usage: groups [NICK]"
        return
      end

      if !user_exists?(bot, args[0])
        m.channel.send "No groups for %s." % args[0]
        return
      end

      groups = get_groups(bot, args[0])
    end

    m.channel.send "Groups for %s: %s" % [arg == "" ? m.user.nick : args[0], groups.join(", ")]
  end

  def pluginban(m, arg)

    args = arg.split(" ")
    if args.length != 1
      print "Usage: pluginban USER"
    end

    moduser(m, args[0]+ " +BANNED")
  end
end
