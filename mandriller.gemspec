require File.expand_path('../lib/mandriller/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "mandriller"
  gem.version     = Mandriller::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ["Daisuke Taniwaki"]
  gem.email       = ["daisuketaniwaki@gmail.com"]
  gem.homepage    = "https://github.com/dtaniwaki/mandriller"
  gem.summary     = "Mandrill SMTP API integration for ActionMailer"
  gem.description = "Mandrill SMTP API integration for ActionMailer"
  gem.license     = "MIT"

  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency "actionmailer", ">= 3.0"
  gem.add_dependency "multi_json"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec", ">= 3.0"
  gem.add_development_dependency "coveralls"
end
