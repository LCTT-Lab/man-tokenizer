require 'json'

input = File.read ARGV[0]
tokens = JSON.parse(input).collect { |block| block['lines'] }.flatten 1

output = tokens.collect do |line|
  line.collect do |token|
    token['content']
  end.join + "\n"
end.join

if ARGV[1] == '-'
  print output
else
  File.write ARGV[1], output
end
