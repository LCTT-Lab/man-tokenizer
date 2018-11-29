require 'json'

token_dir = ARGV[0]

index_json = Dir["#{token_dir}/*/*.json"].to_json
File.write "#{token_dir}/index.json", index_json
