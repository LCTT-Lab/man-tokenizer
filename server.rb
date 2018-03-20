require 'webrick'
require 'yaml'
require 'json'
require './man'


class MyServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_POST request, response
    file = request.query['file']
    return if file.nil?
    use_yaml = !!request.query['yaml']

    status = 200
    case request.path
    when '/tokenize'
      begin
        tokens = ManTokenizer.tokenize file
      rescue ParseError
        status = 500
        body = $!
	return
      end

      output = JSON.pretty_generate tokens
      output = JSON.parse(output).to_yaml.gsub /^---\n/, '' if use_yaml
    when '/assemble'
      if use_yaml
        tokens = YAML.load file
      else
        tokens = JSON.parse file
      end

      output = ManTokenizer.assemble tokens
    else
      status = 404
      output = 'Not Found'
    end

    response.status = status
    response.body = output
  end
end


server = WEBrick::HTTPServer.new(:Port => 3000)

server.mount "/", MyServlet

trap("INT") {server.shutdown}

server.start
