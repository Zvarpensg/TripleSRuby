
#TODO: persist data with sqlite, add permissions
module Authentication

  def user_has_groups?(bot, user, groups)
    return get_missing_groups(bot, user, groups) == []
  end

  def get_missing_groups(bot, user, groups)
    res = bot.config.database.execute "select name from "\
            "users join usergroups on users.id=user_id "\
            "join groups on groups.id=group_id "\
            "where nick=?", user
    existingGroups = []
    res.each do |group|
      existingGroups.push group[0]
    end
    
    return groups - existingGroups
  end

  def require_groups(bot, m, user, groups)
    missingGroups = get_missing_groups(bot, m.user.nick, groups)
    if missingGroups != []
      m.channel.send("You must be a member of groups: %s" % missingGroups.join(", "))
      return false
    end

    return true
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
