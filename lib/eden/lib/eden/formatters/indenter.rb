class Indenter < Eden::Formatter
  def self.format( source_file )
    return unless options[:adjust_indents]
    @current_indent = 0
    source_file.each_line do |line|
      next if line.tokens[0] && line.tokens[0].is?(:heredoc_body)
      calculate_pre_indent(line)
      adjust_indent(line)
      calculate_post_indent(line)
    end
  end

  private
  # Calculates changes in indent relative to the previous line due to tokens in the current line
  def self.calculate_pre_indent( line )
    line.tokens.each do |t|
      if [:end, :rescue, :else, :elsif].include?(t.type)
        @current_indent -= 1 
        line.tokens.each do |tok|
          increase_indent! if [:class, :def, :module].include?(tok.type)
        end
      end

      if t.is?( :when )
        decrease_indent!
      end
    end
    @current_indent = 0 if @current_indent < 0
  end

  def self.calculate_post_indent( line )
    line.tokens.each do |t|
      if [:class, :def, :module, :do, :begin, :rescue, :if, :else, :elsif, :case, :unless].include?(t.type)
        increase_indent!
        
        # Handle suffix conditionals
        if [:if, :unless].include?(t.type)
          prev_token = line.previous_non_whitespace_token(t)
          decrease_indent! if !prev_token.nil? || (prev_token && prev_token.type == :equals)
        end

        line.tokens.each do |tok|
          decrease_indent! if tok.is?( :end )
        end
      end

      if [:for, :until, :while].include?(t.type)
        increase_indent!

        if [:until, :while].include?(t.type)
          prev_token = line.previous_non_whitespace_token(t)
          decrease_indent! if !prev_token.nil? || (prev_token && prev_token.type == :equals)
        end

        line.tokens.each do |tok|
          decrease_indent! if tok.is?( :do )
        end
      end

      if t.is?(:when)
        increase_indent!
      end
    end
  end

  def self.adjust_indent( line )
    return unless line.tokens[0]
    if @current_indent == 0
      line.tokens.delete_at(0) if line.tokens[0].type == :whitespace
    else
      if line.tokens[0].is?( :whitespace )
        line.tokens[0].content = indent_content
      else
        indent_token = Eden::Token.new( :whitespace, indent_content )
        line.tokens.unshift(indent_token)
      end
    end
  end

  def self.indent_content
    options[:indent_character] * (options[:indent_characters_per_step] * @current_indent)
  end

  def self.increase_indent!
    @current_indent += 1
  end

  def self.decrease_indent!
    @current_indent -=1 if @current_indent > 0
  end
end
