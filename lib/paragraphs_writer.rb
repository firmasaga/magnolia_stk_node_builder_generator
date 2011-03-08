require "lib/base_writer"
class ParagraphsWriter < BaseWriter

  def initialize(doc, project_prefix, package_name, output_dir)
    super doc, project_prefix, package_name, output_dir
  end

  def write_paragraph
    puts "processing paragraphs"
    @doc.search("/sv:node/sv:node[@sv:name='paragraphs']/sv:node/sv:node").each do |node|
      write_paragraph_task_class(node)
    end
  end


  def write_paragraph_task_class(node)
    name = node["name"].gsub("stk", "")
    name_with_prefix = @project_prefix + upfirst(name)
    class_name = "#{upfirst(name)}Task"
    class_str = ""

    paragraphs_dir = @output_dir + "/paragraphs"
    Dir.mkdir(paragraphs_dir) unless File.directory?(paragraphs_dir)
    definitions_dir = paragraphs_dir + "/definitions"
    Dir.mkdir(definitions_dir) unless File.directory?(definitions_dir)

    fileName = definitions_dir + "/" + class_name + ".java"
    File.open(fileName, "w") do |f|
      f.print class_str
    end
  end

end