require './app'
require 'sinatra/activerecord/rake'
require 'rake/testtask'

desc "Run all test"
Rake::TestTask.new(name='spec') do |t|
  t.pattern = 'spec/*_spec.rb'
end
