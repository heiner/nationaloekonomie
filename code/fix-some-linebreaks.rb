# -*- coding: utf-8 -*-
require 'termios'

# Don't have $stdin buffered
term = Termios::getattr( $stdin )
term.c_lflag &= ~Termios::ICANON
Termios::setattr( $stdin, Termios::TCSANOW, term )

regex = %r{ ([A-ZÄÖÜ]?[a-zäöüß]+)-
            \s* </p> \s* (?:<p> \s* </p> \s*)?
            (<!--\ page\ [0-9]+\ -->)
            \s* <p> \s*
            ([a-zäöü]+)
          }x

ARGV.each do |fn|
  contents = File.read(fn)
  success = \
  contents.gsub!(regex) do |match|
    # next match if ["http-equiv", "text-align"].include?(match)
    replacement = $1 + $2 + $3

    next replacement

    puts "Change \"#{match}\" to \"#{replacement}\"? "
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

    replacement
  end
  if success
    File.open(fn, "w") do |f|
      f.write(contents)
    end
  else
    puts "No match in #{fn}"
  end
end
