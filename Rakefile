require "bundler/gem_tasks"
require "rspec/core/rake_task"

PARSER_PATH = 'lib/apl/parser.kpeg.rb'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

rule('.kpeg.rb' => -> (target) { target.chomp '.rb' }) do |file|
  sh "bundle exec kpeg -f #{file.source} -o #{file.name}"
end

task build: 'parser:compile'

namespace :parser do
  desc 'Compile the KPeg parser file to Ruby'
  task compile: PARSER_PATH

  desc 'Remove the compiled parser file'
  task :clean do
    rm PARSER_PATH
  end
end