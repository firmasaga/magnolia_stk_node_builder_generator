class NodeBuilderGenerator < Rails::Generators::Base
  require 'ftools'

  source_root File.expand_path('../templates', __FILE__)
  argument :project_prefix, :type => :string #, :default => "my"
  argument :package_name, :type => :string #, :default => "com.my"
  argument :bootstrap_file_name, :type => :string, :default => "config.modules.standard-templating-kit.xml"
  argument :output_dir, :type => :string, :default => "."

  #class_option :stylesheet, :type => :boolean, :default => true, :desc => "Include stylesheet file."


  def generate_node_builder

    folders = ["templates", "paragraphs", "dialogs"]
    temp_file_name = "tmp.config.modules.standard-templating-kit.xml"

    doc = remove_unnecessary_nodes(temp_file_name)

    folders.each do |f|
      puts "processing #{f}"
      eval "write_#{f}(doc, '#{f}')"
    end

    File.delete(temp_file_name)
  end

  private

  def write_paragraphs(doc, folder)
    doc.search("/sv:node/sv:node[@sv:name='#{folder}']/sv:node/sv:node").each do |node|
      name = node["name"].gsub("stk", "")
      @paragraph_name = "#{project_prefix + upfirst(name)}"
      @class_name = "#{upfirst(name)}Task"
      @node = node

      paragraphs_dir = output_dir + "/paragraphs/definitions"
      FileUtils.mkdir_p(paragraphs_dir) unless File.directory?(paragraphs_dir)

      template "paragraph.java.erb", "#{paragraphs_dir}/#{@class_name}.java"
    end
  end

  def write_templates(doc, folder)

  end

  def write_dialogs(doc, folder)
    doc.search("/sv:node/sv:node[@sv:name='#{folder}']/sv:node/sv:node").each do |node|
      name = node["name"].gsub("stk", "")
      @dialog_name = "#{project_prefix + upfirst(name)}"
      @class_name = "#{upfirst(name)}Task"
      @node = node

      dialogs_dir = output_dir + "/dialoghs/definitions"
      FileUtils.mkdir_p(dialogs_dir) unless File.directory?(dialogs_dir)

      template "paragraph.java.erb", "#{dialogs_dir}/#{@class_name}.java"
    end
  end

  def remove_unnecessary_nodes(temp_file_name)
    remove_nodes(bootstrap_file_name, temp_file_name,
                 '//sv:node[@sv:name="MetaData"]',
                 '//sv:property[@sv:name="jcr:primaryType"]',
                 '//sv:property[@sv:name="jcr:mixinTypes"]',
                 '//sv:property[@sv:name="jcr:uuid"]')
  end

  def remove_nodes(input_file_name, output_file_name, *xpaths)
    io = File.open(input_file_name, "r")
    doc = Nokogiri::XML(io)
    io.close

    xpaths.each do |xpath|
      File.open("#{output_file_name}", 'w') do |f|
        doc.search(xpath).each do |node|
          node.remove
        end
        f.puts doc
      end
    end
    doc
  end

  def upfirst(str)
    first = "" << str[0]
    rest = str[1..str.length]
    return first.upcase + rest
  end

  def node_operations(node)
    process_nodes(node)
  end

  def process_nodes(node, out = "")
    first_node = true
    nodes = node.xpath("sv:property")
    sub_nodes = node.xpath("sv:node")
    temp_out = ""

    nodes.each_with_index do |p, i|

      name = p.attr("name").to_s.gsub("stk", @project_prefix)
      value = p.xpath("sv:value").text.to_s.gsub("stk", @project_prefix)
      str = "addProperty(\"#{name}\", \"#{value}\")"
      unless first_node
        str = ",\n" + str
      else
        first_node = false
      end
      out += str
    end

    sub_nodes.each do |sub_sub_node|
      name = sub_sub_node.attr("name").to_s.gsub("stk", @project_prefix)
      #TODO: make dynamic type
      value = "ItemType.CONTENTNODE" #sub_sub_node.xpath("sv:value").text.to_s.gsub("stk", @project_prefix)
      str = "addNode(\"#{name}\", #{value}).then(
                            #{process_nodes(sub_sub_node)}
                    )"
      unless first_node
        str = ",\n" + str
      else
        first_node = false
      end
      temp_out += str

    end

    out += temp_out
  end

end
