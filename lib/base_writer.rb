class BaseWriter
  def initialize(doc, project_prefix, package_name, output_dir)
    @doc = doc
    @project_prefix = project_prefix
    @package_name = package_name
    @output_dir = output_dir
    @level = 0
  end


  def downfirst(str)
    first = "" << str[0]
    rest = str[1..str.length]
    return first.downcase + rest
  end

  def upfirst(str)
    first = "" << str[0]
    rest = str[1..str.length]
    return first.upcase + rest
  end

  def node_operations(node)
    str = process_nodes(node)
    str[0..str.size-2]
  end

  def process_nodes(node, out = "")
    sub_node = node.xpath("sv:node")
    temp_out = ""

    if sub_node.size > 0

      sub_node.each do |sub_sub_node|
        @level += 1
        name = sub_sub_node.attr("name").to_s.gsub("stk", @project_prefix)
        #TODO: make dynamic type
        value = "ItemType.CONTENTNODE" #sub_sub_node.xpath("sv:value").text.to_s.gsub("stk", @project_prefix)
        temp_out += "addNode(\"#{name}\", #{value}).then(
                            #{process_nodes(sub_sub_node, out)}
                    ),\n"
      end
      temp_out = @level > 0 ? temp_out[0..temp_out.size-3] : temp_out[0..temp_out.size-2]
      @level -= 1 if @level > 0
      node.xpath("sv:property").each do |p|
        name = p.attr("name").to_s.gsub("stk", @project_prefix)
        value = p.xpath("sv:value").text.to_s.gsub("stk", @project_prefix)
        out += "addProperty(\"#{name}\", \"#{value}\"),\n"
      end
      out = out[0..out.size-3]
      out += temp_out
    else
      node.xpath("sv:property").each do |p|
        name = p.attr("name").to_s.gsub("stk", @project_prefix)
        value = p.xpath("sv:value").text.to_s.gsub("stk", @project_prefix)
        out += "addProperty(\"#{name}\", \"#{value}\"),\n"
      end

      out =  out[0..out.size-3]
      @level -= 1 if @level > 0
      out += temp_out 
    end
  end
end