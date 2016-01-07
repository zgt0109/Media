require "fileutils"
require "pry"


rails_assets_path = File.join(File.dirname(File.absolute_path(__FILE__)), "../public/mobile")
puts "rails assets path: #{rails_assets_path}"

html_assets_path = File.join(File.dirname(File.absolute_path(__FILE__)), "../../../svn/html/webApp/assets")
puts "html assets path: #{html_assets_path}"

puts "copy entire assets sub folders ..."
files = Dir.glob(File.join(html_assets_path,"/**/*")).reject{|f| f=~/\.svn/}
files.each do |f|
  if File.directory? f
    FileUtils.mkdir_p f.sub(html_assets_path,rails_assets_path)
  else
    FileUtils.cp f, f.sub(html_assets_path,rails_assets_path)
  end
end

=begin
puts "create rails assets folders ..."
FileUtils::mkdir_p File.join(rails_assets_path, "js/lib")
FileUtils::mkdir_p File.join(rails_assets_path, "css/font")
FileUtils::mkdir_p File.join(rails_assets_path, "images")
FileUtils::mkdir_p File.join(rails_assets_path, "img")

puts "copy css and js ..."
files = [ "css/winwemediaV02.css", "css/wbusiness2.css", "css/font/font-awesome.min.css", "js/lib/swipe.js", "js/winwemediaV02.js" ]
files.each do |f|
  FileUtils.cp File.join(html_assets_path, f), File.join(rails_assets_path, f)
end

puts "copy font/images/img files ..."
files = Dir.glob(File.join(html_assets_path,"images/**/*")).reject{|f| f=~/\.svn/} + Dir.glob(File.join(html_assets_path,"img/**/*")).reject{|f| f=~/\.svn/} + Dir.glob(File.join(html_assets_path,"css/font/**/*")).reject{|f| f=~/\.svn/}
files.each do |f|
  if File.directory? f
    FileUtils.mkdir_p f.sub(html_assets_path,rails_assets_path)
  else
    FileUtils.cp f, f.sub(html_assets_path,rails_assets_path)
  end
end
=end

puts "reset css urls"
files = Dir.glob File.join(rails_assets_path, "css/*.css")
files.each do |f_name|
  File.open(f_name, "r+") do |f|
    out = ""
    f.each do |line| 
      if line =~ /\.\.\/img/
        puts line
        puts line_new = line.gsub(/\.\.\/img/, "/mobile/img")
        out << line_new
      else
        out << line
      end

    end
    f.pos = 0
    f.print out
    f.truncate(f.pos)
  end
end

=begin
puts "reset font urls"
files = Dir.glob File.join(rails_assets_path, "css/*.css")
files.each do |f_name|
  File.open(f_name, "r+") do |f|
    out = ""
    f.each do |line| 
      if line =~ /\.\.\/font/
        puts line
        puts line_new = line.gsub(/\.\.\/font/, "/admin/font")
        out << line_new
      else
        out << line
      end

    end
    f.pos = 0
    f.print out
    f.truncate(f.pos)
  end
end
=end
