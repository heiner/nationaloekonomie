# -*- coding: utf-8 -*-

require 'toc'

require 'rubygems'
require 'nokogiri'

require 'pp'

# compute toc
toc = []

depth = [-1, 0, 0, 0]
type = nil
last_page = -1

TOCLIST.each do |title, page|
  if page.kind_of?(Array)
    page, type = page
    case type
    when PART
      depth[1..3] = [0, 0, 0]
    when CHAPTER
      depth[2..3] = [0, 0]
    when SECTION
      depth[3] = 0
    end
  end

  depth[type] += 1

  toc.pop if last_page == page

  name = "p#{depth[PART]}"
  name << "c%02i" % depth[CHAPTER] unless depth[CHAPTER].zero?
  name << "s%02i" % depth[SECTION] unless depth[SECTION].zero?
  name << "e#{depth[EXKURS]}" unless depth[EXKURS].zero?

  toc << [page, name]

  last_page = page
end

#pp toc
#exit

HTML = File.open("book.html")

#doc = Nokogiri::XML(HTML, &:noblanks)
doc = Nokogiri(HTML)
doc.encoding = 'utf-8'
#puts doc.to_xhtml( :indent=>2 )
doc.xpath("//p/a[@id and @name]").each do |tag|
  if tag.next_sibling.text?
    tag.next_sibling.remove
  end
  page = tag.attribute('id').to_s.to_i - 10
  tag.parent.add_next_sibling("<div id=\"#{page}\" />")
  tag.remove
end

#File.open("book-output.html", "w") do |outfile|
#  outfile.write(doc.to_xhtml)
#end

HEADER = <<EOS
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
EOS

FOOTER = "\n</body>\n</html>\n"

file = File.open("output/book-intro.html", "w")
file.write(HEADER)
doc.xpath("//body").children.each do |tag|
  if tag.name == "div"
    page = tag.attribute('id').to_s.to_i
    #puts page

    if !toc.empty? and page == toc.first[0]
      file.write(FOOTER)
      file.close()

      page, name = toc.shift
      file = File.open("output/book-#{name}.html", "w")
      file.write(HEADER)
      file.write("<a id=\"#{name}\" name=\"#{name}\" />\n")
    end
    file.write("<!-- page #{page} -->\n")
    next
  end

  tag.write_to(file, :indent => 2, :encoding => 'UTF-8')
  #file.write(tag.to_xhtml(:indent=>2))
end
file.write(FOOTER)
file.close
