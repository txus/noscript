# encoding: utf-8
require 'bundler'
Bundler::GemHelper.install_tasks

desc "Regenerate Noscript's lexer and parser."
task :regenerate do
  has_rex  = `which rex`
  has_racc = `which racc`

  if has_rex && has_racc
    `rex lib/noscript/parser/noscript.rex`
    `racc lib/noscript/parser/noscript.racc`
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
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end
