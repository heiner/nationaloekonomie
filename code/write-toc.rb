# -*- coding: utf-8 -*-
require 'pp'

require 'rubygems'
require 'builder'

require 'toc'

TOC = []

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

  name = "p#{depth[PART]}"
  name << "c%02i" % depth[CHAPTER] unless depth[CHAPTER].zero?
  name << "s%02i" % depth[SECTION] unless depth[SECTION].zero?
  name << "e#{depth[EXKURS]}" unless depth[EXKURS].zero?

  if last_page == page
    last_type, old_name, last_title = TOC.pop
    TOC << [last_type, name, last_title]
  end

  TOC << [type, name, title]

  last_page = page
end

$counter = 0

def handle_level(level, toc, xml)
  loop do
    break if toc.empty? or toc[0][0] < level

    $counter += 1

    l, data, title = toc.shift
    xml.navPoint(:id=>"navPoint-#{$counter}", :playOrder=>$counter) do
      xml.navLabel { xml.text(title) }
      xml.content(:src=>"book-#{data}.html")

      if l > level
        handle_level(l, toc, xml)
      end
    end
  end
end


if __FILE__ == $0

$KCODE = "UTF8"

File.open("output/toc.ncx", "w") do |f|
  xml = Builder::XmlMarkup.new(:target=>f, :indent=>2)
  xml.instruct!
  xml.declare!( :DOCTYPE, :ncx, :PUBLIC, "-//NISO//DTD ncx 2005-1//EN",
                "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd" )
  xml.ncs(:xmlns=>"http://www.daisy.org/z3986/2005/ncx/", :version=>"2005-1") do
    xml.head do
      xml.meta :name=>"dtb:uid",   :content=>"3-88405-023-0"
      xml.meta :name=>"dtb:depth", :content=>4
      xml.meta :name=>"dtb:totalPageCount", :content=>0
      xml.meta :name=>"dtb:maxPageNumber",  :content=>0
    end
    xml.docTitle  { xml.text "Nationalökonomie" }
    xml.docAuthor { xml.text "Ludwig von Mises" }
    xml.navMap do
      handle_level(0, TOC, xml)
    end
  end
end

# puts toc.select { |type, name, title| type == CHAPTER }.length

end
