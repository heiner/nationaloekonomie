# -*- coding: utf-8 -*-

require 'pp'
require 'English'

require 'write-toc'

pages = TOCLIST.map do |title, page_or_array|
  page_or_array.kind_of?(Integer) ? page_or_array : page_or_array[0]
end

our_toc_list = TOC.zip(pages)
our_toc_list.map! { |entry| entry.flatten }
our_toc_list = our_toc_list.inject(nil) do |list, entry|
  if list.nil?
    [entry]
  else
    page = entry[-1]
    last_page = list[-1][-1]
    if page == last_page
      # don't add entry with same page number
      list
    else
      list << entry
    end
  end
end

def filename(entry)
  "../src/OEBPS/book-#{entry[1]}.html"
end

HEADER = DATA.read

our_toc_list.each_with_index do |entry, index|
  next if index.zero?
  level, data, title, page = entry

  # Handle special cases
  level -= 1 if title == "SCHLUSSWORT"

  content = File.read(filename(entry))
  regex = /<h#{level+1}>(?:[^<]|<\/?i>)+<\/h#{level+1}>/

  list = content.split(regex)
  # if list.length != 2
  #   puts list.length
  #   puts "problem in #{data}, regex was #{regex}, title is #{title}"
  # end

  pre_content = list.first
  content = content[pre_content.length..-1]
  pre_content =~ /\A.*?<body>\n/m
  pre_content = $POSTMATCH
  a_string = "<a id=\"#{data}\" name=\"#{data}\" />\n"
  pre_content.sub!(a_string, "")
  if pre_content =~ /<!-- page [0-9]+ -->\s*\z/
    content = $MATCH + a_string + content
    pre_content = $PREMATCH
  else
    content = a_string + content
  end

  last_entry = our_toc_list[index-1]

  last_content = File.read(filename(last_entry))
  #puts "read #{last_content.length} characters"
  if last_content =~ /<\/body>\n<\/html>/m
    last_content = $PREMATCH
    #puts "will write #{last_content.length} characters"
  else
    puts "problem with #{data}"
    next
  end

  File.open(filename(entry), "w") do |f|
    f.write(HEADER)
    f.write(content)
  end
  File.open(filename(last_entry), "w") do |f|
    f.write(last_content)
    f.write(pre_content)
    f.write("</body>\n</html>\n")
  end
end

__END__
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:ops="http://www.idpf.org/2007/ops">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta http-equiv="Content-Type: text/html; charset=utf-8" />
    <title>Nationalökonomie</title>
    <!--<link rel="stylesheet" type="text/css" href="book-Z-C.css" title="default" />-->
  </head>
  <body>
