# frozen_string_literal: true
source 'https://rubygems.org'

gemspec

gem 'jruby-openssl',	'~> 0.7', platforms: :jruby

# gem 'ronin-support',	       '~> 1.0', github: "ronin-rb/ronin-support",
#                                        branch: 'main'

gem 'ferrum', github: 'rubycdp/ferrum'

group :development do
  gem 'rake'
  gem 'rubygems-tasks', '~> 0.2'

  gem 'rspec',          '~> 3.0'
  gem 'simplecov',      '~> 0.20'

  gem 'kramdown',      '~> 2.0'
  gem 'kramdown-man',  '~> 0.1'

  gem 'rubocop',       require: false, platform: :mri
  gem 'rubocop-ronin', require: false, platform: :mri
  gem 'redcarpet',     platform: :mri

  gem 'yard',            '~> 0.9'
  gem 'yard-spellcheck', require: false

  gem 'dead_end', require: false, platform: :mri
  gem 'sord',     require: false, platform: :mri
end
