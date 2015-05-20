class ManagePlugins
  include Cinch::Plugin
  include Authentication

  match /plugins$/, method: :pluginlist
  match /enable (.+)/, method: :registerplugin
  match /disable (.+)/, method: :unregisterplugin

  def pluginlist(m)
    m.channel.send(@bot.plugins.map {|plugin| plugin.class }.join(", "))
  end

  def registerplugin(m, args)
    admin_and_not_banned(@bot, m) or return
    pluginClass = nil
    begin
      pluginClass = Object.const_get args
    rescue NameError
      m.channel.send "No such plugin #{args}."
      return
    end

    if @bot.plugins.map {|plugin| plugin.class }.include?(pluginClass)
      m.channel.send "#{args} is already active."
      return
    end

    if !pluginClass.included_modules.include?(Cinch::Plugin)
      m.channel.send "No such plugin #{args}."
      return
    end

    @bot.plugins.register_plugin(pluginClass)
    m.channel.send "#{args} enabled."
  end

  def unregisterplugin(m, args)
    admin_and_not_banned(@bot, m) or return
    pluginClass = nil
    begin
      pluginClass = Object.const_get args
    rescue NameError
      m.channel.send "No such plugin #{args}."
      return
    end

    if !pluginClass.included_modules.include?(Cinch::Plugin)
      m.channel.send "No such plugin #{args}."
      return
    end

    if !@bot.plugins.map {|plugin| plugin.class }.include?(pluginClass)
      m.channel.send "#{args} is already inactive."
      return
    end

    plugin = @bot.plugins.find {|plgn| plgn.class == pluginClass }
    @bot.plugins.unregister_plugin(plugin)
    m.channel.send "#{args} disabled."
  end
end
