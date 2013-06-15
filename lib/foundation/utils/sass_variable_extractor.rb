require "set"

class SassVariableExtractor
  # Format: $body-bg: blue !default; // Line comment
  #  Match:     1       2            3  4
  VAR_REGEX = /\$([^:]+):\s*([^; ]+) !default;\s*(\/\/\s*(.*))?/
  FUNC_REGEX = /@function (\S+)\(([^\)]+)\)/
  MIXIN_REGEX = /@mixin (\S+)\(([^\)]+)\)/
  def initialize(filepath)
    raise "Missing File" unless File.exists?(filepath)
    @filepath = filepath
    # @file = File.open(filepath, "r")
    @vars = Set.new
    @functions = Set.new
    @mixins = Set.new
  end

  def extract_sass_variables
    File.open(@filepath, "r") do |f|
      f.lines.each do |line|
        if match=VAR_REGEX.match(line)
          @vars.add({
            name: match[1],
            value: match[2],
            comment: match[4]
          })
        end        
      end
    end
    return nil if @vars.empty?
    @vars
  end

  def extract_sass_functions
    # Capture basic line, use Ruby#split capabilities
    # FUNC_REGEX
    File.open(@filepath, "r") do |f|
      f.lines.each do |line|
        if match=FUNC_REGEX.match(line)
          # puts match.inspect
          function_name   = match[1].strip
          params = match[2].strip
          params = params.to_s.split(",").map do |param|
            s = param.split(":")
            name = s[0]
            default = s[1]
            {:name => name, :default => default}
          end
          @functions.add({:name => function_name, :params => params})
        end
      end
    end
    return nil if @functions.empty?
    @functions
  end

  def extract_sass_mixins
    # Capture2
    # MIXIN_REGEX
    File.open(@filepath, "r") do |f|
      f.lines.each do |line|
        if match=MIXIN_REGEX.match(line)
          # puts match.inspect
          mixin_name   = match[1].strip
          params = match[2].strip
          params = params.to_s.split(",").map do |param|
            s = param.split(":")
            name = s[0]
            default = s[1]
            {:name => name, :default => default}
          end
          @mixins.add({:name => mixin_name, :params => params})
        end
      end
    end
    return nil if @mixins.empty?
    @mixins
  end

  def extract_docs
    @file.rewind
    docs = "\n// #{File.basename(@file.path)}\n"
    started = false
    @file.lines.each do |line|
      if started
        docs += line
        return docs if line.start_with?("// *")
      end
      if line.start_with?("// *") && !started
        started = true
        docs += line
      end
    end
    return docs
  end
end