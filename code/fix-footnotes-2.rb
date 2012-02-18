# -*- coding: utf-8 -*-

require 'English'

require 'write-toc'

data_list = TOC.map { |level, data, title| data }
data_list.uniq!

mark_re = %r{
  \b (?! w3 | xhtml1 | h1 | h2 | h3 | h4 )
  ( [A-ZÄÖÜ]? [a-zöäüß][a-zöäüß]+
  (?: » | “ )? (?: \. | \? | , )? (?: » | “ )? )
  ( [0-9]+ )
}x

def filename(data)
  "../src/OEBPS/book-#{data}.html"
end

data_list.each_with_index do |data, index|
  this_contents = File.read(filename(data))

  while this_contents =~ mark_re
    pre_mark = $PREMATCH
    footnote_mark = $MATCH
    footnote_word = $1
    footnote_number = $2.to_i
    post_mark = $POSTMATCH

    foot_re = %r{ <p> \s*
                  (#{footnote_number} .*?)
                 (</p> | <br> |
                         \n\s* (?= #{footnote_number+1}) )
                }mx
    if post_mark =~ foot_re
      puts "#{footnote_mark}: found matching footnote in same file"
      footnote_p = $MATCH
      footnote = $1
      multiple = ($2 != "</p>")

      if multiple
        post_mark.sub!(footnote_p, "<p>")
      else
        post_mark.sub!(footnote_p, "")
      end

      this_contents = pre_mark + footnote_word +
                      "<sup>[#{footnote_number}]</sup><small>[" +
                      footnote + "]</small>" + post_mark

    else
      next_data = data_list[index+1]
      next_contents = File.read filename(next_data)

      if next_contents !~ foot_re
        puts "#{footnote_mark}: Not found in next file #{filename(next_data)}. This file was #{filename(data)} regex was #{foot_re}"
        exit
      end
      puts "#{footnote_mark}: found matching footnote in next file"

      footnote_p = $MATCH
      footnote = $1
      multiple = ($2 != "</p>")

      if multiple
        next_contents.sub!(footnote_p, "<p>")
      else
        next_contents.sub!(footnote_p, "")
      end

      this_contents = pre_mark + footnote_word +
                      "<sup>[#{footnote_number}]</sup><small>[" +
                      footnote + "]</small>" + post_mark

      File.open(filename(next_data), "w") do |f|
        f.write(next_contents)
      end
    end
  end
  File.open(filename(data), "w") do |f|
    f.write(this_contents)
  end
end
