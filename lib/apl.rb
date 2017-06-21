require "apl/version"
require ENV['PROJECT_ENV'] == 'test' ? ENV['PARSER_PATH'] : 'apl/parser.kpeg.rb'
Dir[File.join File.dirname(__FILE__), "apl/ast/**/*.rb"].each {|file| require file }

module APL
  def self.run(program)
    parser = APL::Parser.new program
    parser.parse # TODO: how should we handle errors?
    parser.result.compute!
  end
end
