# -*- coding: utf-8 -*-

# In book-p1c01s03e3.html

require '../../code/unbuffered-stdin'

hyphenation_re2 =
  %r{
    ([A-ZÄÖÜ]?[a-zäöüß]+\.)\n
    ([A-ZÄÖÜ][a-zäöüß]+)
    }x

ask = true

ARGV.each do |fn|
  contents = File.read(fn)
  regex = hyphenation_re2

  success = \
  contents.gsub!(regex) do |match|
    replacement = $1 + "</p>\n<p>" + $2

    if not ask
      puts "Change #{match.dump} to #{replacement.dump} in #{fn}"
      next replacement
    end
    print "In #{fn}: Change #{match.dump} to #{replacement.dump}? "

    begin
      c = STDIN.getc.chr
      puts unless c == "\n"
      case c
      when 'n', 'N'
        next match
      when 'q'
        exit
      when 'a'
        ask = false
        next replacement
      else
        next replacement
      end
    rescue Interrupt
      exit
    end

    replacement
  end
  if success
    File.open(fn, "w") do |f|
      f.write(contents)
    end
  else
    # puts "No match in #{fn}"
  end
end
