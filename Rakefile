require 'rake/testtask'

# Setup test tasks
Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
end

desc "Build gem and push it to Gemcutter, updating the version on GitHub."
task :publish do
  require File.dirname(__FILE__) + '/lib/cossincalc/version'
  
  verbose(true) do
    sh "git tag v#{CosSinCalc::VERSION}"
    sh "git push origin master --tags"
    sh "gem build mustache.gemspec"
    sh "gem push mustache-#{CosSinCalc::VERSION}.gem"
  end
end
