
require_relative 'reader'
require 'tree'
include Tree
require_relative 'counter'
require_relative 'display'  # deprecate
require_relative 'node'

BEGIN_DOC = '\\begin{document}'
END_DOC = '\\end{document}'

$VERBOSE = false
SAFETY = false
MAX_SAFE_LINES = 530
MONITOR_GET_TOKEN = false

NL = '\\\\'

def signal(tag)
  if @token
    value = @token.value
    if value == "\n"
      value = ''
    end
    puts "parse ".red + "#{tag}: ".blue + "#{@token.type}, #{value}" if $VERBOSE
  else
    value = ''
  end

end

class Token

  attr_reader :type, :value

  def initialize(type, value)
    @type = type
    @value = value
  end

  def to_s
    "#{type}: #{value}"
  end

end

# This is a very rough draft of Parser
# that to a large extent is my experiment
# in trying to understand what eventually
# has to be done.  The end product of
# the parse routine now consists of
# two nodes on the stack, one for the
# header, one for the document body.
# The result of parsing is stored in the
# content field of these nodes.  In a
# forthcoming iterationk, we will have
# an actual tree.  The nodes, instances
# of Tree::TreeNode, are set up to make
# thie possible.

class Parser

  include Display

  attr_accessor :reader, :token, :stack, :rendered_text, :token_stack

  def initialize(text)

    @reader = Reader.new(preprocess(text))
    @reader.lines << Token.new(:end, 'end')
    @stack = []
    @token_stack = []
    @counter = Counter.new

  end

  # Put space around '$', '\[', and '\]' so
  # that they will be recognized as tokens
  def preprocess(text)
    text = text.gsub('$', ' $ ')
    text = text.gsub('\\[', ' \\[ ')
    text.gsub('\\]', ' \\] ')
  end

  ####################################################
  #
  #                   Tokens
  #
  ####################################################


  # Let str = 'ho ho ho {'one', 'two'}, ha ha'
  # Then args(str) = ['one', 'two']
  def args(str)
    args_rx = /{(.*)}/
    arg_match = str.match args_rx
    if arg_match
      arg_str = (str.match args_rx)[1]
      args = arg_str.split(',').map{ |x| x.strip}
    else
      args = []
    end
    args
  end

  def first_arg(str)
    value = args(str)
    if value.count == 0
      nil
    else
      value[0]
    end
  end

  # Tokens are obtained from the Reader using Reader # get_word.
  # and in the case of comments, Reader # get_line
  #
  # Tokens will be
  #   - a commment, that is, a line beginnng with %
  #   - a blank line
  #   - a word.  Words are surrounded by white space.
  # A single character, .e.g. '$' may be a "word"
  #
  # get_token returns a token and also records it
  # in the instance variable @token
  #
  def get_token
    if @token_stack.count > 0
      @token = @token_stack.pop
    else
      word = @reader.get_word

      ## WORD
      if word == :end
        @token = Token.new(:end, 'end')

      ## COMMENT
      elsif word[0] == '%' and @reader.word_index == 0
        @token = Token.new(:comment, word)

      ## BLANK LINE
      elsif word == :blank_line
        @token = Token.new(:blank, "\n")

      ## NEW LINE
      elsif word == '\\\\'
        @token = Token.new(:newline, NL)

      ## BEGIN ...
      elsif word =~ /\\begin/
        arg = first_arg(word)
        if arg == 'document'
          @token = Token.new(:begin_document, 'BEGIN_DOC')
        elsif arg
          @token = Token.new(:begin_environment, arg)
        else
          puts "unknown \\begin token"
          exit(1)
        end

      ## END ...
      elsif word =~ /\\end/
        arg = first_arg(word)
        if arg == 'document'
          @token = Token.new(:end_document, 'END_DOC')
        elsif arg
          @token = Token.new(:end_environment, arg)
        else
          puts "unknown \\end token"
          exit(1)
        end

      ## CONTROL WORD
      elsif word[0] == '\\'
        @token = Token.new(:control_word, word)

      ## $
      elsif word[0] == '$'
        @token = Token.new(:dollar, '$')

      ## WORD
      else
        @token = Token.new(:word, word)
      end

      ## REPORT AND RESCUE
      puts "#{@reader.line_index} #{@token.type}: ".magenta + "#{@token.value}".cyan if MONITOR_GET_TOKEN
      if SAFETY
        if @reader.line_index > MAX_SAFE_LINES
          exit(1)
        end
      end
      @token
    end
  end


  # To parse LL(1) grammars we need one-token
  # look-ahead, and we sometimes need to be
  # able to put back a token that was taken
  # 'by mistake'.
  #
  def put_token
    @token = @reader.put_word
  end

  ####################################################
  #
  #                   Stack
  #
  ####################################################

  # Three methods manipulating or reading
  # the stack.  The stack is intend to hold
  # and help compute oupput of the parser.

  def push_stack(node)
    @stack.push node
  end

  def pop_stack(count=1)
    if count == 1
      @stack.pop
    else
      @stack.pop(count)
    end
  end

  def pop_stack_to_list(count=1)
    if count == 0
      []
    elsif count == 1
      [@stack.pop]
    else
      @stack.pop(count)
    end
  end

  # pop n tokens from stack
  # and push them (from bottom to top)
  # onto th token_stack
  def push_tokens(n)
    list = pop_stack_to_list(n)
    list.reverse!
    list.each do |token|
       @token_stack.push token
    end
  end

  def top_stack
    @stack[-1]
  end

  def stack_size
    @stack.count
  end

  #############################################

  # Create a TreeNode (Tree::TreeNode) with
  # given content.  The name of the node must
  # be unque and so is generated by a counter.
  # The content of the node is generally a hash.

  def new_node(content)
    Node.new(@counter.get, content)
  end

  ####################################################
  #
  #                   Grammar
  #
  ####################################################

  # PRODUCTIONS
  # document = header BEGIN_DOC body END_DOC
  # body = { expr }
  # expr = { text | commment | macro | env | inline_math | display_math }
  # macro = \command \{ {args} \}
  # env = BEGIN_ENV expr END_ENV
  # inline_math = $ math_text #
  # display_math = \[ math_text \]
  #
  #
  # Terminals:
  # BEGIN_DOC = '\begin{document}'
  # END_DOC = '\end{document}'
  # Pseutotermnals
  # BEGIN_ENV = '\begin{' env_name '}'
  # END_ENV = '\end{' env_name '}'


  ####################################################
  #
  #                   Parser
  #
  ####################################################

  # A recursive-descent parser --- the
  # method 'Parse' at the end, preceded
  # by methods for each non-terminal element
  # in the grammar. (THE GRAMMAR AND HENCE
  # THE METHODS SILL NEED WORK)

  # header pushes one node onto the stack with content
  # type: :header
  # value: a string derived from the input
  # text from the beginning up to the token `\begin{document}`
  #
  # XX: the below is too complicated: recode dammit!!
  #

  def macro_defs
    signal('macro_defs')
    get_token
    count = 0
    while !(@token.type == :comment and @token.value == '%%end_macro_defs')
      count +=1
      push_stack @token.value
      get_token
    end
    str = pop_stack_to_list(count).string_join
    node = Node.create(:macro_defs, str)
    push_stack node
    signal('-- exit macro_defs')
  end

  def header
    signal('header')
    count = 0
    while @token.type != :begin_document
      if @token.type == :comment and @token.value == '%%begin_macro_defs'
        macro_defs
      elsif @token.type == :comment
        comment
      else
        text_sequence
      end
      count += 1
      get_token
    end
    display_stack
    header_node = Node.create(:header, 'header')
    header_nodes = pop_stack_to_list(count)
    header_nodes.each do |node|
      header_node << node
    end
    push_stack header_node
    display_stack
    signal '-- exit header'
  end

  # environment pushes one node onto the
  # stack with the following hash as content:
  #
  # type:     :environment
  #
  # env_type: a string representing the particular
  #           environment.  Thus '\begin{theorem}'
  #           will yield env_type: 'theorem'
  #
  # value:    a list representing the body of the environment.
  #           this list will have to be parsed (next iteration!)
  #
  # Suppose that the token '\begin{theorem}' is encountered by the parser.
  # Then the environment method is called with argument 'theorem'.  The
  # body of the environment is recognized by a while loop that terminates
  # when the token '\end{theorem}' is encountered.  An environment may
  # contain environments within it.  These will have to be parsed,
  # and this will require an adjustment to the parser, since don't
  # yet implment 'expr' inside 'environmnt'
  #
  def environment(end_token)
    signal('environment')
    env_type = @token.value
    label = nil
    get_token
    # bracket_log @token, 'env get_token'
    count = 0
    while @token.value != end_token do
      if @token.value =~ /\A\\label/
        macro
        label_node = pop_stack
        label = (label_node.attribute :args)[0]
      else
        expr
      end
      count += 1
      get_token
    end
    environment_list = pop_stack(count)
    if label
      node = Node.create(:environment, environment_list, env_type: env_type, label: label)
    else
      node = Node.create(:environment, environment_list, env_type: env_type)
    end
    push_stack node
    signal '-- exit environment'
  end

=begin

  def environment1(end_token)
    signal('environment1')
    label = nil
    rx = /\\end{(.*)}/
    env_type = (end_token.match rx)[1]
    # push_stack @token
    get_token
    count = 0
    while @token.value != end_token do
      if @token.value =~ /\A\\label/
        macro
        label_node = pop_stack
        label = (label_node.attribute :args)[0]
      else
        push_stack @token
      end
      count += 1
      get_token
    end
    push_stack @token
    count += 1
    environment_list = pop_stack(count)
    if label
      node = Node.create(:environment, environment_list, env_type: env_type, label: label)
    else
      node = Node.create(:environment, environment_list, env_type: env_type)
    end

    push_stack node
  end

  # experimental version
  def environment2(end_token)
    signal('environment2')
    label = nil
    rx = /\\end{(.*)}/
    env_type = (end_token.match rx)[1]
    push_stack @token # BEGIN ENV
    get_token
    count = 0
    while @token.value != end_token do
      if @token.value =~ /\A\\label/
        macro
        label_node = pop_stack
        label = (label_node.attribute :args)[0]
      else
        push_stack @token
      end
      count += 1
      get_token
    end
    # COUNT IS NOW THE NUMBER OF TOKENS BETWEEN BE & EE
    # Phase 1 ended, EE is current token
    mark = @token
    push_token @token
    push_tokens(count)
    # Phase 2 ended
    expr
    # Phase 3 ended
    count = seek(mark)
    environment_list = pop_stack(count)
    if label
      node = Node.create(:environment, environment_list, env_type: env_type, label: label)
    else
      node = Node.create(:environment, environment_list, env_type: env_type)
    end
    push_stack node
  end

=end

  # A text sequence is a sequence words with no in-line math, display
  # math. or macros (control sequences).  A text sequence is a piece
  # of ordinary prose.  The 'text_sequence' method pops nodes off
  # the stack and then pushes a node nto it with content hash
  #
  # type: :text
  # value: a string representing the text sequence
  #
  def text_sequence
    signal('text_sequence')
    count = 1
    push_stack @token.value
    get_token
    while @token.type == :word
      count += 1
      push_stack @token.value
      get_token
    end
    @reader.put_word
    if count > 1
      str = pop_stack(count).string_join
    else
      str = pop_stack
    end
    node = Node.create(:text, str)
    push_stack node
    signal '-- text sequence'
  end


  def comment
    signal('comment')
    count = 0
    while @token.value != "\n"
      push_stack @token.value
      count += 1
      get_token
    end
    push_stack @token.value
    count += 1
    str = pop_stack_to_list(count).string_join
    # puts "COMMENT: [#{str}]".red
    node = Node.create(:comment, str)
    push_stack node
    signal '-- exit comment'
  end

  # inline_math: pops nodes representing tokens in the body
  # of $ ... $, pushing a node with content
  #
  # type: :inline_math
  # value: the ...
  #
  def inline_math
    signal('inline_math')
    count = 0
    push_stack @token.value
    count += 1
    get_token

    while @token.value != '$'
      push_stack @token.value
      count += 1
      get_token
    end
    push_stack @token.value
    count += 1
    str = pop_stack(count).join(' ')
    node = Node.create(:inline_math, str)
    push_stack node
    signal '-- exit inline math'
  end

  # Like the previous, but for \[ ... \]
  #
  def display_math
    signal('display_math')
    get_token
    count = 1
    push_stack @token.value
    get_token
    while @token.value != '\\]'
      count += 1
      push_stack @token.value
      get_token
    end
    str = pop_stack(count).join(' ')
    node = Node.create(:display_math, str)
    # bracket_log str,  'CREATED AS: display_math'
    push_stack node
    signal '-- exit display math'
  end


  # Used by 'macro' to get all of the macro, not just \name
  #
  def paren_count(str)
    left = str.scan /{/
    right = str.scan /}/
    left.count - right.count
  end

  # recognize a macro and push onto the stack the hash
  #
  # type: :macro
  # value : str (e.g. '\foo{one, two}')
  # macro: command_name, e.g., 'foo'
  # args: the list of arguments, e.g., ['one', 'two'] -- could be nil
  #
  def macro
    signal('macro')
    str = @token.value
    cumulative_parent_count = paren_count(str)
    while cumulative_parent_count != 0 do
      get_token
      value = @token.value
      cumulative_parent_count += paren_count(value)
      str << ' ' << value
    end
    name_rx =/\\([a-zA-Z].*?){/
    args_rx = /{(.*)}/

    command_match = str.match name_rx
    if command_match
      command_name = (str.match name_rx)[1].strip
    else
      command_name = str[1..-1]
    end
    arg_match = str.match args_rx
    if arg_match
      arg_str = (str.match args_rx)[1]
      args = arg_str.split(',').map{ |x| x.strip}
    else
      args = []
    end

    # if the macro is '\item', get
    # the associated text and store it in str.
    # This will the value field of the node
    # created below
    if command_name == 'item'
      text_sequence
      text_node = pop_stack
      item_text = text_node.value
      str = item_text.gsub('\\item','').strip
    end
    node = Node.create(:macro, str, macro: command_name, args: args)
    push_stack node
    signal '-- exit macro'
  end

  # expr: a switch for various grammar elements
  def expr
    signal('expr')
   #  puts "token: #{@token.value}".yellow
    if @token.type == :comment
      # puts "comment: #{@token.value}".red
      comment
    elsif @token.type == :begin_environment
      begin_token = @token.value
      end_token = begin_token.gsub('begin', 'end')
      environment(end_token)
    elsif @token.value == '$'
      inline_math
    elsif @token.value == '\\['
      display_math
    elsif @token.value =~ /\\[a-zA-Z].*/
      macro
    elsif @token.value[0] != '\\'
      text_sequence
    else
      push_stack @token.value ## keep going --- XX: is it correct to do this?
    end
    signal '-- exit expression'
  end

  # body: push one node
  # onto the stack with content
  # a list of elments representing
  # the parsed content between
  # '\begin{document}' and '\end{document}'
  #
  # NOTE: This will eventually be a tree
  def body
    signal('body')
    count = 0
    while @token.type != :end_document
      get_token
      if @token.type  != :end_document
        expr
        count += 1
      end
    end
    # push_stack new_node({type: :end_document, value: '\\end{document}'})
    push_stack Node.create( :end_document,  '\\end{document}')
    count += 1
    body_list = pop_stack(count)
    body_node = Node.create(:body, '')
    body_list.each do |node|
      body_node << node
    end
    # puts "body:".red; node.print_tree
    push_stack body_node
    signal '-- exit body'
  end

  # the main method
  def parse
    signal('parse')
    get_token
    header
    if @token and @token.type == :begin_document
      get_token
      body
      if @token.type != :end_document
        error 'missing END_DOC'
      end
    else
      error 'missing BEGIN_DOC'
    end
    body_node = pop_stack
    head_node = pop_stack
    if head_node.nil?
      head_node = Node.create(:header, '')
    end
    if body_node.nil?
      body_node = Node.create(:body, '')
    end

    document_node = Node.create(:documentt, 'document')
    document_node << head_node
    document_node << body_node
    if $VERBOSE
      puts "yield of parse".red
      document_node.print_tree
    end
    push_stack document_node
    signal '-- exit parse'
  end

  ####################################################
  #
  #                   Display
  #
  ####################################################

  def error message
    puts "ERROR: #{message}".red
  end


end
