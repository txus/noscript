# encoding: utf-8
require 'bundler'
Bundler::GemHelper.install_tasks

desc "Regenerate Noscript's lexer and parser."
task :regenerate do
  has_rex  = `which rex`
  has_racc = `which racc`

  if has_rex && has_racc
    `rex lib/noscript/parser/noscript.rex -o lib/noscript/parser/lexer.rb`
    `racc lib/noscript/parser/noscript.y -o lib/noscript/parser/parser.rb`
  else
    puts "You need both Rexical and Racc to do that. Install them by doing:"
    puts
    puts "\t\tgem install rexical"
    puts "\t\tgem install racc"
    puts
    puts "Or just type `bundle install`."
  end
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb'] - FileList['test/integration_test.rb']
  t.verbose = true
end

require 'rake/testtask'
Rake::TestTask.new(:integration) do |t|
  t.libs << "test"
  t.test_files = FileList['test/integration_test.rb']
  t.verbose = true
end

desc 'Run Noscript native tests'
task :native do
  tests = FileList['test/kernel/*.ns']
  tests.each do |test|
    system("./bin/noscript #{test}")
  end
end

task :default => [:regenerate, :test] #, :integration, :native]
