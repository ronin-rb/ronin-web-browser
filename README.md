# ronin-web-browser

[![CI](https://github.com/ronin-rb/ronin-web-browser/actions/workflows/ruby.yml/badge.svg)](https://github.com/ronin-rb/ronin-web-browser/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/ronin-rb/ronin-web-browser.svg)](https://codeclimate.com/github/ronin-rb/ronin-web-browser)

* [Website](https://ronin-rb.dev/)
* [Source](https://github.com/ronin-rb/ronin-web-browser)
* [Issues](https://github.com/ronin-rb/ronin-web-browser/issues)
* [Documentation](https://ronin-rb.dev/docs/ronin-web-browser/frames)
* [Discord](https://discord.gg/6WAb3PsVX9) |
  [Mastodon](https://infosec.exchange/@ronin_rb)

## Description

ronin-web-browser is a Ruby library for automating the Chrome web browser.
ronin-web-browser builds on the [ferrum] gem, and adds additional API methods
that are useful to security researchers.

## Features

* Automates the Chrome web browser.
* Supports running in visible or headless mode.
* Supports using a HTTP proxy.
* Supports event hooks for requests and responses.
* Supports parsing, setting, loading, and saving cookies.
* Supports saving screenshots into a directory or git repository.
* Small memory footprint (~50Kb Ruby + ~600Kb headless Chrome).
* Has 81% documentation coverage.
* Has 82% test coverage.

## Examples

Initialize a headless browser:

```ruby
browser = Ronin::Web::Browser.new
# ...
browser.quit
```

Initialize a visible browser:

```ruby
browser = Ronin::Web::Browser.new(visible: true)
# ...
browser.quit
```

Opening a temporary browser and automatically quitting:

```ruby
Ronin::Web::Browser.open do |browser|
  # ...
end
```

Initializing the browser with a proxy:

```ruby
browser = Ronin::Web::Browser.new(proxy: "http://proxy.example.com:8080")
# ...
```

Go to and screenshot a webpage:

```ruby
Ronin::Web::Browser.open do |browser|
  browser.go_to("https://google.com")
  browser.screenshot(path: "google.png")
end
```

Intercept all requests:

```ruby
browser = Ronin::Web::Browser.new
browser.every_request do |request|
  puts "> #{request.method} #{request.url}"
end

browser.go_to("https://twitter.com/login")
```

Intercept all responses for all requests:

```ruby
browser = Ronin::Web::Browser.new
browser.every_response do |response,request|
  puts "> #{request.method} #{request.url}"

  puts "< HTTP #{response.status}"

  response.headers.each do |name,value|
    puts "< #{name}: #{value}"
  end

  puts response.body
end

browser.go_to("https://twitter.com/login")
```

Evaluate JavaScript within the current page:

```ruby
browser = Ronin::Web::Browser.new
browser.goto('https://github.com')
browser.eval_js('document.cookie')
# => "..."
```

Load a JavaScript file into the current page as a `<script>` tag:

```ruby
browser.load_js(url: 'https://.../file.js')
```

Load JavaScript code into the current page as a `<script>` tag:

```ruby
browser.load_js(content: '...')
```

Inject JavaScript code into *every* page:

```ruby
browser.inject_js('...')
```

See [ferrum] for additional documentation.

## Requirements

* [Ruby] >= 3.0.0
* [ronin-support] ~> 1.0
* [ferrum] ~> 0.13

## Install

```shell
$ gem install ronin-web-browser
```

### Gemfile

```ruby
gem 'ronin-web-browser', '~> 0.1'
```

### gemspec

```ruby
gem.add_dependency 'ronin-web-browser', '~> 0.1'
```

## Development

1. [Fork It!](https://github.com/ronin-rb/ronin-web-browser/fork)
2. Clone It!
3. `cd ronin-web-browser/`
4. `bundle install`
5. `git checkout -b my_feature`
6. Code It!
7. `bundle exec rake spec`
8. `git push origin my_feature`

## License

Copyright (c) 2022-2026 Hal Brodigan (postmodern.mod3@gmail.com)

ronin-web-browser is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

ronin-web-browser is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with ronin-web-browser.  If not, see <https://www.gnu.org/licenses/>.

[Ruby]: https://www.ruby-lang.org
[ronin-support]: https://github.com/ronin-rb/ronin-support#readme
[ferrum]: https://github.com/rubycdp/ferrum#readme
