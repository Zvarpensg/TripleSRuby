#!/usr/bin/env ruby
# encoding: utf-8
class CatFace
  include Cinch::Plugin
  include Authentication

  match "catface"

  def execute(m)
    not_banned?(@bot, m) or return
    m.channel.send("ฅ^•ﻌ•^ฅ")
  end
end
