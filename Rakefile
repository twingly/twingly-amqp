require "bundler/gem_tasks"

begin
  require "rspec/core/rake_task"

  task default: "spec"

  RSpec::Core::RakeTask.new(:spec) do |task|
    task.pattern = "spec/**/*_spec.rb"
  end

  namespace(:spec) do
    RSpec::Core::RakeTask.new(:integration) do |task|
      task.pattern = "spec/integration/**/*_spec.rb"
    end

    RSpec::Core::RakeTask.new(:unit) do |task|
      task.pattern = "spec/unit/**/*_spec.rb"
    end
  end
rescue LoadError
end
