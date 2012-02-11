# -*- coding: utf-8 -*-

require 'erb'

content = ERB.new(DATA.read, nil, "%<>")

title = "Heiners Book"
creator = "Heiner"
identifier = 123
rights = "GPL"
language = "en-US"
source = "source"
publisher = "Pub"
items = [ ["chapter1", "chapter1.html"] ]
itemrefs = items.transpose[0]

# puts content.result

PAGESEP = "\n\n\f"

mises = File.open("Mises_Nationaloekonomie.txt")

title = "Nationalökonomie"
subtitle = "Theorie des Handels und Wirtschaftens"
author = "Ludwig von Mises"
publisher = "Edition Union Genf"
year = 1940

mises.each(PAGESEP) do |page|
  puts page
  $stdin.getc
end

__END__
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf"
         xmlns:dc="http://purl.org/dc/elements/1.1/"
         xmlns:opf="http://www.idpf.org/2007/opf"
         unique-identifier="ISBN" version="2.0">
  <metadata>
    <dc:title><%= title %></dc:title>
    <dc:creator><%= creator %></dc:creator>
    <dc:identifier opf:scheme="ISBN"><%= identifier %></dc:identifier>
    <dc:rights><%= rights %></dc:rights>
    <dc:language><%= language %></dc:language>
    <dc:source><%= source %></dc:source>
    <dc:publisher><%= publisher %></dc:publisher>
    <meta name="cover" content="cover.jpg"/>
  </metadata>
  <manifest>
    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
% items.each do |id, name|
    <item id="<%= id %>" href="<%= name %>" media-type="application/xhtml+xml"/>
% end
  </manifest>
  <spine toc="ncx">
% itemrefs.each do |id|
    <itemref idref="<%= id %>" linear="yes"/>
% end
  </spine>
  <!--<guide>
    <reference href="book.html" type="cover" title="Cover"/>
  </guide>-->
</package>
