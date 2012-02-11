# -*- coding: utf-8 -*-

require 'erb'

require 'write-toc'

opf = ERB.new(DATA.read, nil, "%<>")

title = "Nationalökonomie"
# subtitle = "Theorie des Handels und Wirtschaftens"
# author = "Ludwig von Mises"
creator = "Ludwig von Mises"
identifier = "3-88405-023-0"
# rights = "" #     <dc:rights><%= rights %></dc:rights> %>
language = "de"
source = "http://docs.mises.de/Mises/Mises_Nationaloekonomie.pdf"
publisher = "Edition Union Genf"
# year = 1940

items = TOC.map { |type, data, header| [data, "book-#{data}.html"] }
items.uniq!

itemrefs = items.transpose[0]

File.open("output/content.opf", "w") do |f|
  f.write(opf.result)
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
    <dc:language><%= language %></dc:language>
    <dc:source><%= source %></dc:source>
    <dc:publisher><%= publisher %></dc:publisher>
    <!--<meta name="cover" content="cover.jpg"/>-->
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
  <guide>
    <reference href="book-intro.html" type="cover" title="Cover"/>
  </guide>
</package>
