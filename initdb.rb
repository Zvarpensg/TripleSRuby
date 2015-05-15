#!/usr/bin/ruby
require 'rubygems'
require 'bundler/setup'
require 'sqlite3'
require 'json'
botJSON = ""

File.open("./bot.json") do |file|
  botJSON = JSON.parse file.read
end

SQLite3::Database.new botJSON["database"] do |db|
  File.open("./schema.sql") do |file|
    db.execute_batch file.read
  end
end
