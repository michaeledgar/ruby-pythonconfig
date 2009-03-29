require 'delegate'
# = PythonConfig
# Class for parsing and writing Python configuration files created by the
# ConfigParser classes in Python. These files are structured like this:
#    [Section Name]
#    key = value
#    otherkey: othervalue
#    
#    [Other Section]
#    key: value3
#    otherkey = value4
#
# Leading whitespace before values are trimmed, and the key must be the at the
# start of the line - no leading whitespace there. You can use : or = .
#
# Multiline values are supported, as long as the second (or third, etc.) lines
# start with whitespace:
#
#    [Section]
#    bigstring: This is a very long string, so I'm not sure I'll be
#      able to fit it on one line, but as long as
#     there is one space before each line, I'm ok. Tabs work too.
#
# Also, this class supports interpolation:
#    [Awards]
#    output: Congratulations for winning %(prize)!
#    prize: the lottery
# Will result in:
#    config.sections["Awards"]["output"] == "Congratulations for winning the lottery!"
#
# You can also access the sections with the dot operator, but only with all-lowercase:
#    [Awards]
#    key:value
#    [prizes]
#    lottery=3.2 million
#
#    config.awards["key"] #=> "value"
#    config.prizes["lottery"] #=> "3.2 million" 
# 
# You can modify any values you want, though to add sections, you should use the add_section
# method.
#    config.sections["prizes"]["lottery"] = "100 dollars" # someone hit the jackpot
#    config.add_section("Candies")
#    config.candies["green"] = "tasty"
# When you want to output a configuration, just call its +to_s+ method.
#    File.open("output.ini","w") do |out|
#      out.write config.to_s
#    end
module PythonConfig
  VERSION = '1.0.1'
  MAX_INTERPOLATION_DEPTH = 200
  # Don't make recursive interpolating values!
  class InterpolationTooDeepError < StandardError; end
  # This is the main class that handles configurations. You parse, modify, and output
  # through this class. See the README for tons of examples.
  class ConfigParser
    attr_reader :sections
    
    SECTION_REGEXP = /\[([^\[\]]*)\]/
    ASSIGNMENT_REGEXP = /([^:=\s]+)\s*[:=]\s*([^\n]*?)$/
    LONG_HEADER_REGEXP = /^([ \t]+)([^\n]+)$/
    # Creates a new ConfigParser. If +io+ is provided, the configuraiton file is read
    # from the io.
    def initialize(io = nil)
      @sections = {}
      io.each do |line|
        parse_line line
      end unless io.nil?
    end
    
    def parse_line line #:nodoc:
    
      if line =~ SECTION_REGEXP
        section_name = $1
        @cursection = add_section section_name
      elsif line =~ ASSIGNMENT_REGEXP
        @cursection[$1] = $2
        @cur_assignment = $1
      elsif line =~ LONG_HEADER_REGEXP
        @cursection[@cur_assignment] += " " + $2
      end
    end
    
    # Returns the names of all the sections, which can be used for keys into the sections
    def section_names
      @sections.keys
    end
    
    # Creates a new section, with the values as provided by the (optional) values parameter
    def add_section(section_name, values={})
      newsection = ConfigSection.new(values)
      @sections[section_name] = newsection
      self.instance_eval %Q{
        def #{section_name.downcase}
          @sections["#{section_name}"]
        end
      }
      newsection
    end
    
    # Returns the section given by +section+
    def [](section)
      @sections[section]
    end
    
    # Returns the configuration as a string that can be output to a file. Does not perform
    # interpolation before writing.
    def to_s
      output = ""
      @sections.each do |k,v|
        output << "[#{k}]\n"
        output << v.to_s
      end
      output
    end
        
  end
  # = ConfigSection
  # This is a simple section in a config document - treat it exactly like a hash,
  # whose keys are the keys in the config, and whose value are the values in the config.
  #
  # This is a separate class entirely because it has to handle the magical interpolation
  # that allows this ini file:
  #    [Awards]
  #    output: Congratulations for winning %(prize)!
  #    prize: the lottery
  # To result in:
  #    config.sections["Awards"]["output"] == "Congratulations for winning the lottery!"
  #
  class ConfigSection < DelegateClass(Hash)
    def initialize(source)
      @source_hash = source
      super(@source_hash)
    end
    def [](key) #:nodoc:
      str = @source_hash[key]
      interpolate(str)
    end
    
    def interpolate(str, cur_depth=0) #:nodoc:
      raise InterpolationTooDeepError.new("Interpolation too deep!") if cur_depth > PythonConfig::MAX_INTERPOLATION_DEPTH
      nextval = str
      nextval = str.gsub(/\%\((.*)\)/,@source_hash[$1]) if str =~ /%\((.*)\)/
      nextval = interpolate(nextval,cur_depth+1) if nextval =~ /%\((.*)\)/
      nextval
    end
    
    def to_s #:nodoc:
      output = ""
      @source_hash.each do |k,v|
        output << "#{k} = #{v.gsub(/\n/,"\n ")}" << "\n"
      end
      output
    end
  end
end
