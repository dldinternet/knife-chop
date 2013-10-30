# Eden

Eden is a source-code formatter for Ruby. It's designed around a robust lexical analyzer able to handle
most of the dark corners of Ruby syntax, and able to be easily modified and extended.

## Installation

Eden is available as a gem. To install it, simply run:

    gem install eden

## Configuration

Eden's formatter modules are able to be configured using a Ruby configuration DSL. Eden loads defaults when it
starts, but if you wish to override options on a project-specific basis, you can do so by creating
a file `config/eden.rb`. For example, if you wish to use tabs instead of spaces to indent a project's code, put
the following in `config/eden.rb`:

    Indenter.configure do |i|
      i.indent_characters_per_step 1
      i.indent_character "\t"
    end

Refer to `lib/eden/defaults.rb` for full configuration options.

## Using Eden

Eden is designed to be used with a source-control system, so when it formats Ruby source files, it writes changes
to the file in place. The basic format for running Eden is:

    eden command filenames

Eden understands 2 commands:

 * `colorize` - Displays a ANSI colorized version of the source. This is mainly used for debugging the lexer.
 * `rewrite` - Rewrites the source files in place to be correctly formatted

Examples:

    eden rewrite source_file.rb

will rewrite source_file.rb

    eden rewrite ./**/*.rb

will rewrite all the .rb files in the current directory and any subdirectories.

Eden was created by Jason Langenauer (jason@jasonlangenauer.com or @jasonlangenauer on Twitter). Any feedback/comments/suggestions gratefully received.