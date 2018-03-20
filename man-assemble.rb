require 'json'
require './man'

input = File.read ARGV[0]
tokens = JSON.parse input

puts ManTokenizer.assemble tokens
