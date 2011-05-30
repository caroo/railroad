module ModelsDiagramShared
  # Load model classes
  def load_classes
    begin
      disable_stdout
      files = Dir.glob("app/models/**/*.rb")
      files += Dir.glob("vendor/plugins/**/app/models/*.rb") if @options.plugins_models
      files -= @options.exclude
      files.each {|m| require m }
      enable_stdout
    rescue LoadError
      enable_stdout
      print_error "model classes"
      raise
    end
  end

  def generate
    STDERR.print "Generating #{self.class.name.tableize.humanize.downcase}\n" if @options.verbose
    cd 'app/models' do
      files = Dir["**/*.rb"]
      files -= @options.exclude
      generate_for_files files
    end
    if @options.plugins_models
      plugins_models = Dir["vendor/plugins/**/app/models/"]
      for plugins_model in plugins_models
        cd plugins_model do
          files += Dir.glob("**/*.rb")
          files -= @options.exclude
          generate_for_files files
        end
      end
    end
  end
end
