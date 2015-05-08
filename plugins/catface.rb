#!/usr/bin/env ruby
# encoding: utf-8
class CatFace
  include Cinch::Plugin

  match "catface"

  def execute(m)
    m.channel.send("ฅ^•ﻌ•^ฅ")
  end
end
