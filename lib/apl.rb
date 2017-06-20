require "apl/version"
require 'apl/parser'
Dir[File.join File.dirname(__FILE__), "apl/ast/**/*.rb"].each {|file| require file }

module APL
  # Your code goes here...
end
