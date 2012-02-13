# -*- coding: utf-8 -*-

ARGV.each do |fn|
  contents = File.read(fn)
  contents.gsub!(/<a href="#[0-9]+">([^<]*)<\/a>/) do |match|
    # next match if ["http-equiv", "text-align"].include?(match)
    replacement = $1
    puts "Change \"#{match}\" to \"#{replacement}\"? "
    replacement
  end
  File.open(fn, "w") do |f|
    f.write(contents)
  end
end
