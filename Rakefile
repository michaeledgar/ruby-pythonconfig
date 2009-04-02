# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/pythonconfig.rb'

Hoe.new('pythonconfig', PythonConfig::VERSION) do |p|
  # p.rubyforge_name = 'pythonconfigx' # if different than lowercase project name
  p.developer('Michael J. Edgar', 'adgar@carboni.ca')
  desc 'Pushes rdocs to carbonica'
  task :carbonica => :redocs do
    sh "scp -r doc/ adgar@carboni.ca@carboni.ca:/var/www/html/projects/#{p.name}/"
  end
end

# vim: syntax=Ruby
