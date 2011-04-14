$LOAD_PATH.unshift 'lib'

require 'rake/testtask'
require 'rake/clean'

# TESTING =====================================================================

task :default => :test
desc 'Run tests (default)'
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/suite.rb']
  t.ruby_opts = ['-rubygems'] if defined? Gem
end

# DOCUMENTATION ===============================================================

# Bring in Rocco tasks
require 'rocco/tasks'
Rocco::make 'docs/'

desc 'Build Globot docs'
task :docs => :rocco
directory 'doc/'

desc 'Build docs and open in browser for the reading'
task :read => :docs do
  sh 'open doc/lib/globot.html'
end

# Make index.html a copy of globot.html
file 'doc/index.html' => 'doc/lib/globot.html' do |f|
  cp 'doc/lib/globot.html', 'doc/index.html', :preserve => true
end
task :docs => 'doc/index.html'
CLEAN.include 'doc/index.html'

# Alias for docs task
task :doc => :docs
