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
    [ type, { type: type, content: content } ]
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

require 'yaml'

mt = ManTokenizer.new
input = File.read ARGV[0]

begin
  mt.parse(input).each do |token|
    # print (token[:type] == :NEWLINE && "\n" || token[:content])
    if token[:type] == :NEWLINE
      puts "\n"
    else
      puts "#{token[:type]}: |#{token[:content]}|"
    end
  end
rescue ParseError
  puts $!
end