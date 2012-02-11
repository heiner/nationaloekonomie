require 'rubygems'
require 'builder'

MIME_NCX = "application/x-dtbncx+xml"
MIME_XHTML = "application/xhtml+xml"

xml = Builder::XmlMarkup.new(:target=>$stdout, :indent=>2)

xml.instruct!
xml.package("xmlns"=>"http://www.idpf.org/2007/opf",
            "xmlns:dc"=>"http://purl.org/dc/elements/1.1/",
            "xmlns:opf"=>"http://www.idpf.org/2007/opf",
            "unique-identifier"=>"ISBN", "version"=>"2.0") {
  xml.metadata {
    xml.dc :title, "Testbook"
    xml.dc :creator, "Author"
    xml.dc :identifier, "Test", "opf:scheme"=>"ISBN"
    xml.dc :rights, "My licence"
    xml.dc :language, "en-US"
    xml.dc :source, "google.com"
    xml.dc :publisher, "Heiner Press"
  }
  xml.manifest {
    xml.item :id=>"ncx", :href=>"toc.ncx", "media-type"=>MIME_NCX
    xml.item :id=>"book", :href=>"book.html", "media-type"=>MIME_XHTML
  }
  xml.spine(:toc=>"ncx") {
    xml.itemref :idref=>"book", :linear=>"yes"
  }
  xml.guide {
    xml.reference :href=>"book.html", :type=>"cover", :title=>"Cover"
  }
}

