require './man'

DEBUG=!!ENV["DEBUG"]
require (DEBUG and 'yaml' or 'json')

input = File.read ARGV[0]

begin
  tokens = ManTokenizer.tokenize input

  if DEBUG
    output = tokens.to_yaml.gsub /^---\n/, ''
  else
    output = JSON.pretty_generate tokens
  end
  puts output
rescue ParseError
  puts $!
end
