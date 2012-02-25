# -*- coding: utf-8 -*-

# In book-p1c01s03e3.html

require 'English'

require '../../code/unbuffered-stdin'

hyphenation_re2 =
  %r{
    ([A-ZÄÖÜ]?[a-zäöüß]+\s
     [A-ZÄÖÜ]?[a-zäöüß]+\s
     [A-ZÄÖÜ]?[a-zäöüß]+\s
     [A-ZÄÖÜ]?[a-zäöüß]+\s
     [A-ZÄÖÜ]?[a-zäöüß]+\.)\n
    ([A-ZÄÖÜ][a-zäöüß]+)
    }x

#title = "Nationaloekonomie"
title = "VIERTER TEIL"
$okular_window = %x{xdotool search --title "#{title}"}.chomp
fail if $okular_window.empty?

$key_hash = {
  'ä' => "adiaeresis",
  'ö' => "odiaeresis",
  'ü' => "udiaeresis",
  'ß' => "ssharp",
  'Ä' => "Adiaeresis",
  'Ö' => "Odiaeresis",
  'Ü' => "Udiaeresis"
}

def pdf_find_umlaute(string, window=$okular_window)
  %x{xdotool windowactivate #{window}}
  %x{xdotool key ctrl+f}

  string.split(/([äöüßÖÄÜ])/u).each do |substring|
    if $key_hash.has_key?(substring)
      %x{xdotool key #{$key_hash[substring]}}
    else
      %x{xdotool type "#{substring}"}
    end
  end
end

def pdf_find(string, window=$okular_window)
  %x{xdotool windowactivate #{window}}
  %x{xdotool key ctrl+f}

  string = string.split(/[äöüßÖÄÜ]/u).last
  %x{xdotool type "#{string}"}
end

ARGV.each do |fn|
  contents = File.read(fn)
  regex = hyphenation_re2

  success = \
  contents.gsub!(regex) do |match|
    replacement = $1 + "</p>\n<p>" + $2

    search = $1

    pre, post = $PREMATCH, $POSTMATCH
    if post =~ /<!-- page (\d+) -->/
      page = $1.to_i - 1
    else
      pre =~ /<!-- page (\d+) -->/
      page = $1.to_i
    end
    pdf_find(search)
    print "In #{fn}, page #{page}: " \
          "Change #{match.dump} to #{replacement.dump}? "

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
