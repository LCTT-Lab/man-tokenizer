# man-tokenizer

class ManTokenizer
rule
  target: lines

  lines  : line { result = [val[0]] }
         | lines line { result = val[0] + [val[1]] }

  line   : tokens NEWLINE { result = val[0] }
         | NEWLINE { result = [] }
  
  tokens : token { result = [val[0]] }
         | tokens token { result = val[0] + [val[1]] }

  token  : COMMENT
         | CONTROL
         | ESCAPE
         | TEXT
end

---- inner

  # m_ignore = %w(TH LP RS RE TP)
  # m_block  = %w(SH BR)
  # m_inline = %w(B IR I RI)

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
        @q.push node(:ESCAPE, $&)
      when /\A\n/o
        @q.push node(:NEWLINE, $&)
      when /\A[^\\\n]+/o
        @q.push node(:TEXT, $&)
      when /\A\\/o
        @q.push node(:ESCAPE, $&)
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
