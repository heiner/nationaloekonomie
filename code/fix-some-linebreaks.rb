# -*- coding: utf-8 -*-

require '../../code/unbuffered-stdin'

### Regex for hyphenated word
hyphenation_re =
  %r{ ([A-ZÄÖÜ]?[a-zäöüß]+)-
      \s* </p> \s* (?:<p> \s* </p> \s*)?
      (<!--\ page\ [0-9]+\ -->)
      \s* <p> \s*
      ([a-zäöü]+)
    }x

### Regex for broken-up sentence
broken_sentence_re =
  %r{ ([A-ZÄÖÜ]?[a-zäöüß]+
       (?: \  | , | \s*&mdash;\s* | )
      )
      \s* </p> \s* (?:<p> \s* </p> \s*)?
      (<!--\ page\ [0-9]+\ -->)
      \s* <p> \s*
      ([A-ZÄÖÜ]?[a-zäöü]+)
    }x

### Regex for broken-up paragraphs
### Should probably not be "fixed"!
# broken_paragraph_re = %r{ ([A-ZÄÖÜ]?[a-zäöüß]+\.)
#             \s* </p> \s* (?:<p> \s* </p> \s*)?
#             (<!--\ page\ [0-9]+\ -->)
#             \s* <p> \s*
#             ([A-ZÄÖÜ][a-zäöü]+)
#           }x

broken_sentence_re2 =
  %r{ ([A-ZÄÖÜ]?[a-zäöüß]+
       (?: \  | ,\ ? | \s*&mdash;\s* )?
      )
      \s* <br> \s*
      ([A-ZÄÖÜ]?[a-zäöü]+)
    }x

hyphenation_re2 =
  %r{ ([A-ZÄÖÜ]?[a-zäöüß]+)-
      \s* <br> \s*
      ([a-zäöü]+)
    }x

ask = true

ARGV.each do |fn|
  contents = File.read(fn)
  regex = hyphenation_re2

  success = \
  contents.gsub!(regex) do |match|
    # replacement = $1 + $2 + $3             # hyphenation_re
    # replacement = $1 + $2 + " " + $3       # broken_sentence_re
    # replacement = $1 + " " + $2 + " " + $3 # broken_paragraph_re

    replacement = $1 + $2                    # re2

    puts "Change \"#{match}\" to \"#{replacement}\"? "
    if not ask
      next replacement
    end

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
