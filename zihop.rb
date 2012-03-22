require "webrick"
require "webrick/httpproxy"
require "stringio"
require "zlib"
require "rexml/document"

handler = Proc.new do |req, res|
	begin
		if res["content-type"] == "text/xml; charset=UTF-8"
			marquee_xml = res.body
			if res.header["content-encoding"] == "gzip"
				Zlib::GzipReader.wrap(StringIO.new(marquee_xml)) do |gz|
					marquee_xml = gz.read
				end
				res.header.delete("content-encoding")
				res.header.delete("content-length")
			end

			xml = REXML::Document.new(marquee_xml)
			xml.elements.each("/marquee_data/marquee/just_time") do |element|
				start_time = element.text
				if start_time[-2, 2] == "00"
					del_marquee = element.parent unless element.nil?
					xml.root.delete(del_marquee)
				end
			end
			marquee_xml = xml.to_s
		end
	rescue
		marquee_xml = res.body
	ensure
		res.body = marquee_xml
	end
end


config = {
	:BindAddress => "127.0.0.1",
	:Port => 8080,
	:ProxyVia => false,
	:ProxyContentHandler => handler
}

zihop = WEBrick::HTTPProxyServer.new(config)
[:INT, :TERM].each do |sig|
	Signal.trap(sig) { zihop.shutdown }
end

zihop.start