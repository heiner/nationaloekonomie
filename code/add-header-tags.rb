# -*- coding: utf-8 -*-

require 'termios'

# Don't have $stdin buffered
term = Termios::getattr( $stdin )
term.c_lflag &= ~Termios::ICANON
Termios::setattr( $stdin, Termios::TCSANOW, term )

require 'write-toc'

TOC.each do |level, data, title|
  filename = "../src/OEBPS/book-#{data}.html"

  start = title[0..5]
  ending = title[-5..-1]
  start.gsub!("(", "\\(")
  start.gsub!(")", "\\)")
  ending.gsub!("(", "\\(")
  ending.gsub!(")", "\\)")

  case level
  when CHAPTER
    regex = /<p>\s*<i>\s*(#{start}[^<>]*#{ending}.?)\s*<\/i>\s*<\/p>/i
    replacement = "<h2>\\1</h2>"
  when SECTION
    regex = /<p>\s*(#{start}[^<>]*#{ending}.?)\s*<\/p>/
    replacement = "<h3>\\1</h3>"
  when EXKURS
    if title =~ /^Exkurse?: (.*)/
      title = $1
    end
    regex = /<p>\s*#{title}\s*<\/p>/
    replacement = "<h4>#{title}</h4>"
  else
    next
  end

  begin
    content = File.read(filename)
    success = content.sub!(regex, replacement)
    if success
      puts "#{regex} matched"
      File.open(filename, "w") do |f|
        f.write(content)
      end
    else
      if level == CHAPTER
        if not content =~ /<h2>\s*(#{start}[^<>]*#{ending}.?)\s*<\/h2>/i
          puts "No success for #{level}, #{data}, #{title}"
        end
      end

      # if level == SECTION
      #   if not content =~ /<h3>\s*(#{start}[^<>]*#{ending}.?)\s*<\/h3>/
      #     puts "No success for #{data}, \"#{title}\""
      #   end
      # end
    end
  rescue Errno::ENOENT => e
    puts e
  end
end
