# man-tokenizer

class ManTokenizer
rule
  target        : blocks

  # Blocks

  blocks        : block        { result = [val[0]] }
                | blocks block { result = val[0] + [val[1]] }

  block         : comment_lines {
                      result = { "type" => "comment", "lines" => val[0] }
                  }
                | macro_lines {
                      result = { "type" => "macro",   "lines" => val[0] }
                  }
                | content_lines {
                      result = { "type" => "content", "lines" => val[0] }
                  }
                | empty_lines   {
                      result = { "type" => "empty",   "lines" => val[0] }
                  }

  # Block --- comment lines

  comment_lines : comment_line               { result = [val[0]] }
                | comment_lines comment_line { result = val[0] + [val[1]] }

  comment_line  : COMMENT_BLOCK NEWLINE      { result = [val[0]] }

  # Block --- macro lines

  macro_lines : macro_line { result = [val[0]] }

  macro_line  : MACRO_BLOCK tokens NEWLINE { result = [val[0]] + val[1] }
              | MACRO_BLOCK NEWLINE        { result = [val[0]] }

  # Block --- content lines

  content_lines : content_line               { result = [val[0]] }
                | content_lines content_line { result = val[0] + [val[1]] }

  content_line  : token tokens NEWLINE { result = [val[0]] + val[1] }
                | token NEWLINE        { result = [val[0]] }

  # Block --- empty lines

  empty_lines   : NEWLINE             { result = [[]] }
                | empty_lines NEWLINE { result = val[0] + [[]] }

  # Tokens

  tokens        : token        { result = [val[0]] }
                | tokens token { result = val[0] + [val[1]] }

  token         : COMMENT_INLINE
                | MACRO_INLINE
                | ESCAPE
                | TEXT
end

---- inner

  macro_tokens = lambda do |type, len|
    "(#{type.select do |ctl|
      ctl.length == len
    end.collect do |token|
      Regexp.escape token
    end.join('|')})"
  end

  IGNORE_BLOCK   = %w(. ad BI Bl bp br Bd Bx Dd de ds DT Dt Ed El el fam
                      fi Fn ft HP hy ie if In in It LP na ne nf nh nr ns
                      Os P PD PP Pp RE RS so sp ta TH ti TP TS UC)
  REG_MACRO_IGNORE_BLOCK_1   = /\A[.']#{macro_tokens.call IGNORE_BLOCK,   1}/o
  REG_MACRO_IGNORE_BLOCK_2   = /\A[.']#{macro_tokens.call IGNORE_BLOCK,   2}/o
  REG_MACRO_IGNORE_BLOCK_3   = /\A[.']#{macro_tokens.call IGNORE_BLOCK,   3}/o

  CONTENT_BLOCK  = %w(IP SH Sh SS Ss TE)
  REG_MACRO_CONTENT_BLOCK_2  = /\A[.']#{macro_tokens.call CONTENT_BLOCK,  2}/o

  IGNORE_INLINE  = %w(B BR Dv Fa I IB IR Li Nm RB RI UE UR)
  REG_MACRO_IGNORE_INLINE_1  = /\A[.']#{macro_tokens.call IGNORE_INLINE,  1}/o
  REG_MACRO_IGNORE_INLINE_2  = /\A[.']#{macro_tokens.call IGNORE_INLINE,  2}/o

  CONTENT_INLINE = %w(Nd q)
  REG_MACRO_CONTENT_INLINE_1 = /\A[.']#{macro_tokens.call CONTENT_INLINE, 1}/o
  REG_MACRO_CONTENT_INLINE_2 = /\A[.']#{macro_tokens.call CONTENT_INLINE, 2}/o

  REG_COMMENT_BLOCK  = /\A[.']\\".*/o
  REG_COMMENT_INLINE = /\A\\".*/o

  REG_ESCAPE  = /\A\\(\(..|.)/o # FIXME: need handle each escape separately.
  REG_NEWLINE = /\A\n/o
  REG_TEXT    = /\A[^\\\n]+/o
  REG_WARP    = /\A\\/o

  def node(type, content, translatable = nil)
    ret = [ type, { 'type' => type.to_s, 'content' => content } ]
    ret[1]['translatable'] = translatable unless translatable.nil?
    ret
  end

  def parse(str)
    line_begin = true
    @q = []
    until str.empty?
      match_first = false

      if line_begin
        match_first = true
        line_begin = false
        case str
        when REG_COMMENT_BLOCK
          @q.push node(:COMMENT_BLOCK, $&)
        when REG_MACRO_IGNORE_BLOCK_3
          @q.push node(:MACRO_BLOCK, $&, false)
        when REG_MACRO_IGNORE_BLOCK_2
          @q.push node(:MACRO_BLOCK, $&, false)
        when REG_MACRO_CONTENT_BLOCK_2
          @q.push node(:MACRO_BLOCK, $&, true)
        when REG_MACRO_IGNORE_INLINE_2
          @q.push node(:MACRO_INLINE, $&, false)
        when REG_MACRO_CONTENT_INLINE_2
          @q.push node(:MACRO_INLINE, $&, true)
        when REG_MACRO_IGNORE_BLOCK_1
          @q.push node(:MACRO_BLOCK, $&, false)
        when REG_MACRO_IGNORE_INLINE_1
          @q.push node(:MACRO_INLINE, $&, false)
        when REG_MACRO_CONTENT_INLINE_1
          @q.push node(:MACRO_INLINE, $&, true)
        else
          match_first = false
        end
      end

      if not match_first
        case str
        when REG_COMMENT_INLINE
          @q.push node(:COMMENT_INLINE, $&)
        when REG_ESCAPE
          @q.push node(:ESCAPE, $&)
        when REG_NEWLINE
          @q.push node(:NEWLINE, $&)
          line_begin = true
        when REG_TEXT
          @q.push node(:TEXT, $&)
        when REG_WARP
          @q.push node(:ESCAPE, $&)
        end
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

require (!!ENV["YAML"] and 'yaml' or 'json')

mt = ManTokenizer.new
input = File.read ARGV[0]

begin
  tokens = mt.parse input

  if !!ENV["YAML"]
    output = tokens.to_yaml.gsub /^---\n/, ''
  else
    output = JSON.pretty_generate tokens
  end
  puts output
rescue ParseError
  puts $!
end
