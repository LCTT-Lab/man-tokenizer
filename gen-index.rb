require 'json'

token_dir = ARGV[0]

index_list = Dir["#{token_dir}/*/*.json"].map do |file|
  file.gsub /^[^\/]*\//, ''
end
File.write "#{token_dir}/index.json", JSON.pretty_generate(index_list)
