# -*- coding: utf-8 -*-
require 'termios'

# Don't have $stdin buffered
term = Termios::getattr( $stdin )
term.c_lflag &= ~Termios::ICANON
Termios::setattr( $stdin, Termios::TCSANOW, term )

regex = %r{ ([A-ZÄÖÜ]?[a-zäöüß]+\.)
            \s* </p> \s* (?:<p> \s* </p> \s*)?
            (<!--\ page\ [0-9]+\ -->)
            \s* <p> \s*
            ([A-ZÄÖÜ][a-zäöü]+)
          }x

ARGV.each do |fn|
  contents = File.read(fn)
  success = \
  contents.gsub!(regex) do |match|
    replacement = $1 + " " + $2 + " " + $3

    print "Change \"#{match}\" to \"#{replacement}\"? "
    # next match

    begin
      c = STDIN.getc.chr
      puts unless c == "\n"
      case c
      when 'n', 'N'
        next match
      when 'q'
        exit
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
