# -*- coding: utf-8 -*-

require 'termios'

# Don't have $stdin buffered
term = Termios::getattr( $stdin )
term.c_lflag &= ~Termios::ICANON
Termios::setattr( $stdin, Termios::TCSANOW, term )

ARGV.each do |fn|
  contents = File.read(fn)
  contents.gsub!(/([A-ZÄÖÜ]?[a-zäöüß]+)-([a-zäöüß]+)/) do |match|
    next match if ["http-equiv", "text-align"].include?(match)
    replacement = $1 + $2
    print "Change #{match} to #{replacement}? "
    begin
      c = STDIN.getc.chr
      puts unless c == "\n"
      case c
      when 'n', 'N'
        match
      else
        replacement
      end
    rescue Interrupt
      exit
    end
  end
  File.open(fn, "w") do |f|
    f.write(contents)
  end
end
