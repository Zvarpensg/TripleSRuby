
#TODO: persist data with sqlite, add permissions
module Authentication
  def get_groups(bot, user)
    res = bot.config.database.execute "select name from "\
        "users join usergroups on users.id=user_id "\
        "join groups on groups.id=group_id "\
        "where nick=?", user
    groups = []
    res.each do |group|
      groups.push group[0]
    end

    return groups
  end

  def has_groups(bot, m, groups)
    missingGroups = groups - get_groups(bot, m.user.nick)
    if missingGroups != []
      m.channel.send "You require group%s %s." % [missingGroups.length == 1 ? "" : "s:", missingGroups.join(", ")]
      return false
    end

    return true
  end

  def no_groups(bot, m, groups)
    badGroups = groups & get_groups(bot, m.user.nick)
    if badGroups != []
      m.channel.send "You can't use this with group%s %s." % [badGroups.length == 1 ? "" : "s:", badGroups.join(", ")]
      return false
    end

    return true
  end

  def admin_and_not_banned(bot, m)
    return has_groups(bot, m, ["ADMIN"]) && no_groups(bot, m, ["BANNED"])
  end

  def not_banned?(bot, m)
    return no_groups(bot, m, ["BANNED"])
  end

  def user_id(bot, user)
    res = bot.config.database.execute "select id from users where nick=?", user
    return res.nil? ? nil : res[0] # only one result is possible, unique constraint
  end

  def group_id(bot, group)
    res = bot.config.database.execute "select id from groups where name=?", group
    return res.nil? ? nil : res[0]
  end

  def user_exists?(bot, user)
    return !user_id(bot, user).nil?
  end

  def group_exists?(bot, group)
    return !group_id(bot, group).nil?
  end
end
