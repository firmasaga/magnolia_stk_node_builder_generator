require "lib/base_writer"
class TemplatesWriter < BaseWriter

  def initialize(doc, project_prefix, package_name, output_dir)
    super doc, project_prefix, package_name, output_dir
  end

  def write
    puts "processing templates"
    @doc.search("/sv:node/sv:node[@sv:name='templates']/sv:node").each do |node|
      write_template_task_class(node)
    end
  end


  def write_template_task_class(node)
    name = node["name"].gsub("stk", "")
    name_with_prefix = @project_prefix + upfirst(name)
    class_name = "#{upfirst(name)}Task"
    class_str = "package #{@package_name}.templates.definitions;

              import com.baloise.cms.internet.setup.tasks.templates.AbstractTemplateConfigBuilderTask;
              import info.magnolia.cms.core.ItemType;
              import info.magnolia.nodebuilder.NodeOperation;
              import info.magnolia.nodebuilder.task.ErrorHandling;

              import static info.magnolia.nodebuilder.Ops.addNode;
              import static info.magnolia.nodebuilder.Ops.addProperty;

              /**
               * Created by Ruby Node Buildergenerator
               * User: dschlegel, Namics AG
               * Date: #{Time.now.strftime("%d/%m/%Y")}
               * Time: #{Time.now.strftime("%I:%M%p")}
               */
              public class #{class_name} extends AbstractTemplateConfigBuilderTask {
                  private final static String TEMPLATE_KEY = \"#{name_with_prefix}\";

                  public #{class_name}() {
                      super(TEMPLATE_KEY, ErrorHandling.strict);
                  }


                  @Override
                  protected NodeOperation[] getNodeOperations() {
                      return new NodeOperation[]{
                          #{node_operations(node)}
                      };
                  }
              }"

    templates_dir = @output_dir + "/templates"
    Dir.mkdir(templates_dir) unless File.directory?(templates_dir)
    definitions_dir = templates_dir + "/definitions"
    Dir.mkdir(definitions_dir) unless File.directory?(definitions_dir)

    fileName = definitions_dir + "/" + class_name + ".java"
    File.open(fileName, "w") do |f|
      f.print class_str
    end
  end

end