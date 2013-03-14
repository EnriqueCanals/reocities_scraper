require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'fileutils'
require 'timeout'


###
# By. Enrique Canals and Julio Capote
# Inspired by a boring night and some time to kill.
# USAGE: ruby scrape.rb <neighborhood>
#
# See http://www.reocities.com/neighborhoods/ for a list of neighborhoods
#
###

start_site = ARGV[0]
index_page = open("http://www.reocities.com/#{start_site}/").read

def collect_links(index_page)
  hrefs = []
  Nokogiri::HTML(index_page).search('a').each do |el|
    value = el.attributes['href'].value
    hrefs << value if value != "/" and value.to_s.to_f != 0.0
  end
  hrefs
end

def collect_images(page, start_site, site)
  Nokogiri::HTML(page).search('img').each do |el|
    value = el.attributes['src'].value
    next if value.include?('pixel.gif')

    file_name = value.split('/').last

    path = "pics/#{start_site}/#{site}"

    if value.include?('http://')
      url = value
    else
      url = "http://www.reocities.com/#{start_site}/#{site}/#{value}"
    end

    begin
      unless File.exists?("#{path}/#{file_name}")
        file_data = open(url).read
        puts "  writing #{url} #{path}"

        FileUtils.mkdir_p(path)
    Timeout::timeout (2) do
        File.open("#{path}/#{file_name}", "wb") { |f| f.print file_data }
        end
      end
    rescue
    end
  end
end

links = collect_links(index_page)


links.shuffle.each do |link|
  puts "going to #{link}"
  begin
    collect_images(open("http://www.reocities.com/#{start_site}/#{link}/index.html"), start_site, link)
  rescue
  end
end