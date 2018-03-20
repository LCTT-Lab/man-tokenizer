require './man'

DEBUG=!!ENV["DEBUG"]
require (DEBUG and 'yaml' or 'json')

mt = ManTokenizer.new

input = File.read ARGV[0]

begin
  tokens = mt.parse input

  if DEBUG
    output = tokens.to_yaml.gsub /^---\n/, ''
  else
    output = JSON.pretty_generate tokens
  end
  puts output
rescue ParseError
  puts $!
end
