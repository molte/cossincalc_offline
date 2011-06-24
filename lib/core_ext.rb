# Taken from Active Support (copyright (c) 2005-2008 David Heinemeier Hansson),
# which is realeased under the MIT license as part of the Ruby on Rails framework.
# http://github.com/rails/rails/blob/babbc1580da9e4a23921ab68d47c7c0d2e8447da/activesupport/lib/active_support/core_ext/symbol.rb

unless :to_proc.respond_to?(:to_proc)
  class Symbol
    # Turns the symbol into a simple proc, which is especially useful for enumerations. Examples:
    #
    # # The same as people.collect { |p| p.name }
    # people.collect(&:name)
    #
    # # The same as people.select { |p| p.manager? }.collect { |p| p.salary }
    # people.select(&:manager?).collect(&:salary)
    def to_proc
      Proc.new { |*args| args.shift.__send__(self, *args) }
    end
  end
end

# Changes working directory to the directory in which the file of the given path
# resides, and executes the given block within this directory. Passes the
# basename of the file (including extension) as an argument to the block.
def Dir.cd_to(filepath)
  Dir.chdir(File.dirname(filepath)) { yield(File.basename(filepath)) }
end
