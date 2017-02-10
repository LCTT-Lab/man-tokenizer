# man-tokenizer

class ManTokenizer
rule
  target        : blocks

  # Blocks

  blocks        : block { result = [val[0]] }
                | blocks block { result = val[0] + [val[1]] }

  block         : comment_lines
                | control_lines
                | content_lines
                | empty_lines

  # Block --- comment lines

  comment_lines : comment_line { result = [val[0]] }
                | comment_lines comment_line { result = val[0] + [val[1]] }

  comment_line  : COMMENT_BLOCK NEWLINE { result = [val[0]] }

  # Block --- control lines

  control_lines : control_line { result = [val[0]] }

  control_line  : CONTROL_BLOCK tokens NEWLINE { result = [val[0]] + val[1] }
                | CONTROL_BLOCK NEWLINE { result = [val[0]] }

  # Block --- content lines

  content_lines : content_line { result = [val[0]] }
                | content_lines content_line { result = val[0] + [val[1]] }

  content_line  : token tokens NEWLINE { result = [val[0]] + val[1] }
                | token NEWLINE { result = [val[0]] }

  # Block --- empty lines

  empty_lines   : NEWLINE { result = [[]] }
                | empty_lines NEWLINE { result = val[0] + [[]] }

  # Tokens

  tokens        : token { result = [val[0]] }
                | tokens token { result = val[0] + [val[1]] }

  token         : COMMENT_INLINE
                | CONTROL_INLINE
                | ESCAPE
                | TEXT
end

---- inner

  control_tokens = lambda do |type, len|
    "(#{type.select { |ctl| ctl.length == len }.join('|')})"
  end
  TOK_CONTROL_IGNORE = %w(TH LP RS RE TP)
  #REG_CONTROL_IGNORE_1 = /\A[.']#{control_tokens.call TOK_CONTROL_IGNORE, 1}/o
  REG_CONTROL_IGNORE_2 = /\A[.']#{control_tokens.call TOK_CONTROL_IGNORE, 2}/o
  TOK_CONTROL_BLOCK = %w(SH BR)
  #REG_CONTROL_BLOCK_1 = /\A[.']#{control_tokens.call TOK_CONTROL_BLOCK, 1}/o
  REG_CONTROL_BLOCK_2 = /\A[.']#{control_tokens.call TOK_CONTROL_BLOCK, 2}/o
  TOK_CONTROL_INLINE = %w(IR RI B I)
  REG_CONTROL_INLINE_1 = /\A[.']#{control_tokens.call TOK_CONTROL_INLINE, 1}/o
  REG_CONTROL_INLINE_2 = /\A[.']#{control_tokens.call TOK_CONTROL_INLINE, 2}/o

  def node(type, content)
    [ type, { 'type' => type.to_s, 'content' => content } ]
  end

  def parse(str)
    first = true
    reset = false
    @q = []
    until str.empty?
      case str
      when /\A[.']\\".*/o
        if first
          first = false
          @q.push node(:COMMENT_BLOCK, $&)
        else
          # For text end with a '.' followed by inline comment.
          @q.push node(:TEXT, '.')
          @q.push node(:COMMENT_INLINE, $&[1..-1])
        end
      when REG_CONTROL_INLINE_2
        @q.push node(:CONTROL_INLINE, $&)
      when REG_CONTROL_BLOCK_2
        if first
          first = false
          @q.push node(:CONTROL_BLOCK, $&)
        else
          # FIXME: handle control block not at beginning of the line.
          @q.push node(:TEXT, $&) # FIXME: parse as text for now.
        end
      when REG_CONTROL_IGNORE_2
        # FIXME: add new syntax rules.
        if first
          first = false
          @q.push node(:CONTROL_BLOCK, $&)
        else
          # FIXME: handle control block not at beginning of the line.
          @q.push node(:TEXT, $&) # FIXME: parse as text for now.
        end
      when REG_CONTROL_INLINE_1
        @q.push node(:CONTROL_INLINE, $&)
      when /\A[.'][A-Z]{1,2}/o
        # FIXME: don't trait other control as block token.
        if first
          first = false
          @q.push node(:CONTROL_BLOCK, $&)
        else
          # FIXME: handle control block not at beginning of the line.
          @q.push node(:TEXT, $&) # FIXME: parse as text for now.
        end
      when /\A\\".*/o
        @q.push node(:COMMENT_INLINE, $&)
      when /\A\\(\(..|.)/o
        @q.push node(:ESCAPE, $&)
      when /\A\n/o
        @q.push node(:NEWLINE, $&)
        reset = true
      when /\A[^\\\n]+/o
        @q.push node(:TEXT, $&)
      when /\A\\/o
        @q.push node(:ESCAPE, $&)
      end
      str = $'
      first = false
      if reset
        reset = false
        first = true
      end
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
