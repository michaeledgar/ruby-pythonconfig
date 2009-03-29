= pythonconfig

* http://www.carboni.ca/

== DESCRIPTION:

PythonConfig is a module with classes for parsing and writing Python configuration 
files created by the ConfigParser classes in Python. These files are structured like this:
   [Section Name]
   key = value
   otherkey: othervalue
   
   [Other Section]
   key: value3
   otherkey = value4

Leading whitespace before values are trimmed, and the key must be the at the
start of the line - no leading whitespace there. You can use : or = .

Multiline values are supported, as long as the second (or third, etc.) lines
start with whitespace:

   [Section]
   bigstring: This is a very long string, so I'm not sure I'll be
     able to fit it on one line, but as long as
    there is one space before each line, I'm ok. Tabs work too.

Also, this class supports interpolation:
   [Awards]
   output: Congratulations for winning %(prize)!
   prize: the lottery
Will result in:
   config.sections["Awards"]["output"] == "Congratulations for winning the lottery!"

You can also access the sections with the dot operator, but only with all-lowercase:
   [Awards]
   key:value
   [prizes]
   lottery=3.2 million

   config.awards["key"] #=> "value"
   config.prizes["lottery"] #=> "3.2 million" 

You can modify any values you want, though to add sections, you should use the add_section
method.
   config.sections["prizes"]["lottery"] = "100 dollars" # someone hit the jackpot
   config.add_section("Candies")
   config.candies["green"] = "tasty"
When you want to output a configuration, just call its +to_s+ method.
   File.open("output.ini","w") do |out|
     out.write config.to_s
   end

== FEATURES/PROBLEMS:

* Multiple sections are parsed
* Interpolation using %(key) supported
* Multiline values supported

== SYNOPSIS:

See the Description.

== REQUIREMENTS:

* none

== INSTALL:

* sudo gem install pythonconfig

== LICENSE:

(The MIT License)

Copyright (c) 2009 FIX

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
