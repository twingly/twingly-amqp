require "bundler/gem_tasks"

begin
  require "rspec/core/rake_task"

  task default: "spec"

  desc "Run all tests"
  RSpec::Core::RakeTask.new(:spec) do |task|
    task.pattern = "spec/**/*_spec.rb"
  end

  namespace(:spec) do
    desc "Run integration tests"
    RSpec::Core::RakeTask.new(:integration) do |task|
      task.pattern = "spec/integration/**/*_spec.rb"
    end

    desc "Run unit tests"
    RSpec::Core::RakeTask.new(:unit) do |task|
      task.pattern = "spec/unit/**/*_spec.rb"
    end
  end
rescue LoadError
end
