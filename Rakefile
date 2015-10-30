require "bundler/gem_tasks"

begin
  require "rspec/core/rake_task"

  task default: "spec"

  RSpec::Core::RakeTask.new(:spec) do |task|
    task.pattern = "spec/twingly/**/*_spec.rb"
  end
rescue LoadError
end
