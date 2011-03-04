require "lib/writer"
require "nokogiri"

if ARGV.length != 3
  print "usage:  ruby gen.rb bootStrapFile projectPrefix packageName\n"
  exit
end

puts `pwd`

project_prefix = ARGV[1]
package_name = ARGV[2]
output_dir = ARGV[3]

writer = Writer.new(project_prefix, package_name, output_dir)
writer.write
