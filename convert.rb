# This project is a fork from https://gist.github.com/1254319 that I  updated
# ~ (http://richardsondx.github.com)

#!/usr/bin/env ruby -Ku

require "nokogiri"
require "iconv"


# opens every file in the given dir tree and converts any html img tags to rails image_tag calls
#
# example usage: 
# ruby convert.rb ~/my_rails_app/app/views
#
# ***be careful and backup before using this***
#

raise "no directory tree given" if ARGV.first.nil?

path = "#{ARGV.first}/**/*"

@count = {
  :files_open => 0,
  :files_revised => 0,
  :tags => 0
}

class RailsImageTag
  
  Params = [
    { :name => :alt }, 
    { :name => :height, :type => :int },
    { :name => :width, :type => :int },
    { :name => :class }, 
    { :name => :title },
    { :name => :id }
  ]
  
  def initialize(img)
    @img = img
  end
  
  # construct and return the erb containing the new image_tag call
  def to_erb
    url = @img['src']
    
    # remove img/asset prefix
    url.gsub!("img/assets/", "")

    
    "<%= image_tag('#{url}'#{options_to_erb}) %>"
  end
  
  # convert the img tag params to image_tag options
  # the params to process are defined in the Params constant hash
  def options_to_erb
    options_erb = {}
    Params.each do |opt|
      name = opt[:name]
      value = @img[name]
      value = opt[:type] != :int ? "'#{value}'" : value  
      options_erb[name] = ":#{name} => #{value}" unless value.nil? or value == "''"
    end
    options_erb.empty? ? "" : ", " + options_erb.values.join(", ") 
  end
  
end

class HtmlDoc
  
  def initialize(filename)
    @name = filename
    file = File.open(@name)
    @doc = Nokogiri::HTML(file)
    @content = File.open(@name) { |f| f.read }
  end
  
  # overwrite the file with new contents
  def write_file(log, content)
    new_name = "#{@name}.new"
    puts "writing file #{new_name}"
    
    log[:files_revised] += 1
    File.open(new_name, "w+") do |f| 
       puts "file is writeable? #{ File.writable?(f) }"
      f.write content
    end
  end
  
  # convert a single file and record stats to <em>log</em>
  def convert_img_tags!(log)
    log[:files_open] += 1
    file_marked = false
    @doc.xpath("//img").each do |img| 
      file_marked = true
      log[:tags] += 1
      
      # handle '`gsub!': invalid byte sequence in UTF-8 (ArgumentError)' error
      ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')
      original = ic.iconv(original)
      @content = ic.iconv(@content)
      
      #puts "BEFORE: " + img.to_html
      
      original = img.to_html.gsub("\">", "\" />").gsub("\" >", "\" />").delete("\\")
      # we need a second version of the original in case our image tag is like this: <img src="a.gif" alt=""/>
      original2 = img.to_html.gsub("\">", "\"/>").delete("\\")

      # p img.to_html
      p "Convertion to IMAGE TAG ----"
      p RailsImageTag.new(img).to_erb

      @content = @content.gsub(original, RailsImageTag.new(img).to_erb)
      @content = @content.gsub(original2, RailsImageTag.new(img).to_erb)
      
      #puts @content
      
    end
    write_file(log, @content) if file_marked
  end
  
end

Dir.glob(path).each { |filename| HtmlDoc.new(filename).convert_img_tags!(@count) if File.file?(filename) }

p "***********************************"
p "#{@count[:files_open]} files opened"
p "#{@count[:files_revised]} files revised"
p "#{@count[:tags]} tags replaced"