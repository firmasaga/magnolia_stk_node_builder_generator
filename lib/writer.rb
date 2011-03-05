require "lib/paragraphs_writer"
require "lib/templates_writer"
require "lib/dialogs_writer"
class Writer
  def initialize(project_prefix, package_name, output_dir)
    @project_prefix = project_prefix
    @package_name = package_name
    @output_dir = output_dir

  end

  def write
    io = File.open(File.dirname(__FILE__) + "/../" + ARGV[0], "r")
    @doc = Nokogiri::XML(io)
    io.close

    remove_unnecessary_nodes

    io = File.open(File.dirname(__FILE__) + "/../tmp." + ARGV[0], "r")
    cleaned_doc = Nokogiri::XML(io)
    io.close

    paragraphs_writer = ParagraphsWriter.new(cleaned_doc, @project_prefix, @package_name, @output_dir)
    paragraphs_writer.write

    templates_writer = TemplatesWriter.new(cleaned_doc, @project_prefix, @package_name, @output_dir)
    templates_writer.write
  end

  def remove_unnecessary_nodes
    remove_nodes '//sv:node[@sv:name="MetaData"]',
                 '//sv:property[@sv:name="jcr:primaryType"]',
                 '//sv:property[@sv:name="jcr:mixinTypes"]',
                 '//sv:property[@sv:name="jcr:uuid"]'
  end

  def remove_nodes(*xpaths)
    xpaths.each do |xpath|
      File.open("tmp.#{ARGV[0]}", 'w') do |f|
        @doc.search(xpath).each do |node|
          node.remove
        end
        f.puts @doc
      end
    end
  end
end