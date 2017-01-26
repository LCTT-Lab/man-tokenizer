require 'json'

input = File.read ARGV[0]
tokens = JSON.parse input

puts tokens.collect{ |token| token["content"] }.join
