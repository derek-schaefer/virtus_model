require 'rspec/core/rake_task'
require 'rdoc/task'

RSpec::Core::RakeTask.new('spec')

RDoc::Task.new do |rdoc|
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :spec

desc 'Build the gem'
task :build => [:spec, :rdoc] do
  system 'gem build *.gemspec'
end

desc 'Remove build files'
task :clean do
  system 'rm -r html/ *.gem'
end
