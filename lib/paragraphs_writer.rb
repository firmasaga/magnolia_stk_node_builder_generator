require "lib/base_writer"
class ParagraphsWriter < BaseWriter

  def initialize(doc, project_prefix, package_name, output_dir)
    super doc, project_prefix, package_name, output_dir
  end

  def write
    puts "processing paragraphs"
    @doc.search("/sv:node/sv:node[@sv:name='paragraphs']/sv:node/sv:node").each do |node|
      write_paragraph_task_class(node)
    end
  end


  def write_paragraph_task_class(node)
    name = node["name"].gsub("stk", @project_prefix)
    class_str = "package #{@package_name}.paragraphs.definitions;

              import com.baloise.cms.internet.setup.tasks.paragraphs.AbstractParagraphConfigBuilderTask;
              import info.magnolia.nodebuilder.NodeOperation;
              import info.magnolia.nodebuilder.task.ErrorHandling;

              import static info.magnolia.nodebuilder.Ops.addProperty;

              /**
               * Created by Ruby Node Buildergenerator
               * User: dschlegel, Namics AG
               * Date: #{Time.now.strftime("%d/%m/%Y")}
               * Time: #{Time.now.strftime("%I:%M%p")}
               */
              public class #{upfirst(name)}Task extends AbstractParagraphConfigBuilderTask {
                  private final static String PARAGRAPH_KEY = \"#{name}\";

                  public TextImageTask() {
                      super(PARAGRAPH_KEY, ErrorHandling.strict);
                  }


                  @Override
                  protected NodeOperation[] getNodeOperations() {
                      return new NodeOperation[]{
                          #{node_operations(node)}
                      };
                  }
              }"

    paragraphs_dir = @output_dir + "/paragraphs/"
    Dir.mkdir(paragraphs_dir) unless File.directory?(paragraphs_dir)

    fileName = @output_dir + "/paragraphs/" + upfirst(name.gsub(@project_prefix, "")) + "Task.java"
    f = File.new(fileName, "w");

    f.print class_str
    f.close()
  end

end