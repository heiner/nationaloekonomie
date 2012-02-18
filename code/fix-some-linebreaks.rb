# -*- coding: utf-8 -*-

require '../../code/unbuffered-stdin'

### Regex for hyphenated word
# regex = %r{ ([A-ZÄÖÜ]?[a-zäöüß]+)-
#             \s* </p> \s* (?:<p> \s* </p> \s*)?
#             (<!--\ page\ [0-9]+\ -->)
#             \s* <p> \s*
#             ([a-zäöü]+)
#           }x

### Regex for broken-up sentence
regex = %r{ ([A-ZÄÖÜ]?[a-zäöüß]+(?:\ |,))
            \s* </p> \s* (?:<p> \s* </p> \s*)?
            (<!--\ page\ [0-9]+\ -->)
            \s* <p> \s*
            ([A-ZÄÖÜ]?[a-zäöü]+)
          }x

### Regex for broken-up paragraphs
### Should probably not be "fixed"!
# regex = %r{ ([A-ZÄÖÜ]?[a-zäöüß]+\.)
#             \s* </p> \s* (?:<p> \s* </p> \s*)?
#             (<!--\ page\ [0-9]+\ -->)
#             \s* <p> \s*
#             ([A-ZÄÖÜ][a-zäöü]+)
#           }x

ARGV.each do |fn|
  contents = File.read(fn)
  success = \
  contents.gsub!(regex) do |match|
    # replacement = $1 + $2 + $3
    replacement = $1 + $2 + " " + $3
    # replacement = $1 + " " + $2 + " " + $3

    print "Change \"#{match}\" to \"#{replacement}\"? "
    next replacement

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
