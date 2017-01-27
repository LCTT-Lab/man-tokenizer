# man-tokenizer

class ManTokenizer
rule
  target: tokens
  
  tokens: token { result = [val[0]] }
        | tokens token { result = val[0] + [val[1]] }

  token: COMMENT
       | CONTROL
       | SPECIAL
       | NEWLINE
       | TEXT
end

---- inner

  def node(type, content)
    [ type, { 'type' => type.to_s, 'content' => content } ]
  end
  
  def parse(str)
    @q = []
    until str.empty?
      case str
      when /\A[.']?\\".*/o
        @q.push node(:COMMENT, $&)
      when /\A[.']../o
        @q.push node(:CONTROL, $&)
      when /\A\\(\(..|.)/o
        @q.push node(:SPECIAL, $&)
      when /\A\n/o
        @q.push node(:NEWLINE, $&)
      when /\A[^\\\n]+/o
        @q.push node(:TEXT, $&)
      when /\A\\/o
        @q.push node(:SPECIAL, $&)
      end
      str = $'
    end
    @q.push [false, '$end']
    do_parse
  end

  def next_token
    @q.shift
  end

---- footer

DEBUG=!!ENV["DEBUG"]
require (DEBUG and 'yaml' or 'json')

mt = ManTokenizer.new
input = File.read ARGV[0]

begin
  raw_tokens = mt.parse input

  tokens = []
  line_buffer = []
  raw_tokens.each do |tok|
    if tok['type'] == 'NEWLINE'
      tokens.push line_buffer
      line_buffer = []
    else
      line_buffer.push tok
    end
  end

  if DEBUG
    output = tokens.to_yaml.gsub /^---\n/, ''
  else
    output = JSON.pretty_generate tokens
  end
  puts output
rescue ParseError
  puts $!
end
