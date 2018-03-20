require 'webrick'
require 'yaml'
require 'json'
require './man'


class MyServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_POST request, response
    begin
      mt = ManTokenizer.new
      tokens = mt.parse request.query['file']

      output = JSON.pretty_generate tokens
      if request.query['debug']
        output = JSON.parse(output).to_yaml.gsub /^---\n/, ''
      end
      response.body = output
      response.status = 200
    rescue ParseError
      response.status = 500
      response.body = $!
    end
  end
end


server = WEBrick::HTTPServer.new(:Port => 3000)

server.mount "/", MyServlet

trap("INT") {server.shutdown}

server.start
