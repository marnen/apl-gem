require 'tempfile'

tempfile = Tempfile.new ['parser', '.rb']

parser_path = File.join(File.dirname(__FILE__), '../../lib/apl/parser.kpeg')
system 'bundle', 'exec', 'kpeg', '-o', tempfile.path, '--force', parser_path
ENV['PARSER_PATH'] = tempfile.path

RSpec.configure do |config|
  config.after(:suite) do
    tempfile.unlink
  end
end