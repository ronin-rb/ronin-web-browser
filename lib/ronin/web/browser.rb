# frozen_string_literal: true
#
# ronin-web-browser - An automated Chrome API.
#
# Copyright (c) 2022-2023 Hal Brodigan (postmodern.mod3@gmail.com)
#
# ronin-web-browser is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-web-browser is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with ronin-web-browser.  If not, see <https://www.gnu.org/licenses/>.
#

require 'ronin/web/browser/agent'
require 'ronin/web/browser/version'

module Ronin
  module Web
    #
    # Automates a Chrome web browser.
    #
    # ## Examples
    #
    # Initialize a headless browser:
    #
    # ```ruby
    # browser = Ronin::Web::Browser.new
    # # ...
    # browser.quit
    # ```
    #
    # Initialize a visible browser:
    #
    # ```ruby
    # browser = Ronin::Web::Browser.new(visible: true)
    # # ...
    # browser.quit
    # ```
    #
    # Opening a temporary browser and automatically quitting:
    #
    # ```ruby
    # Ronin::Web::Browser.open do |browser|
    #   # ...
    # end
    # ```
    #
    # Initializing the browser with a proxy:
    #
    # ```ruby
    # browser = Ronin::Web::Browser.new(proxy: "http://proxy.example.com:8080")
    # # ...
    # ```
    #
    # Go to and screenshot a webpage:
    #
    # ```ruby
    # Ronin::Web::Browser.open do |browser|
    #   browser.go_to("https://google.com")
    #   browser.screenshot(path: "google.png")
    # end
    # ```
    #
    # Intercept all requests:
    #
    # ```ruby
    # browser = Ronin::Web::Browser.new
    # browser.network.intercept
    # browser.on(:request) do |request|
    #   puts "> #{request.method} #{request.url}"
    #   request.continue
    # end
    #
    # browser.go_to("https://twitter.com/login")
    # ```
    #
    # Intercept all responses for all requests:
    #
    # ```ruby
    # browser = Ronin::Web::Browser.new
    # browser.on(:response) do |exchange|
    #   puts "> #{exchange.request.method} #{exchange.request.url}"
    #
    #   puts "< HTTP #{exchange.response.status}"
    #
    #   exchange.response.headers.each do |name,value|
    #     puts "< #{name}: #{value}"
    #   end
    #
    #   puts exchange.response.body
    # end
    #
    # browser.go_to("https://twitter.com/login")
    # ```
    #
    # See [ferrum] for additional documentation.
    #
    # [ferrum]: https://github.com/rubycdp/ferrum#readme
    #
    module Browser
      #
      # Initializes the browser agent.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Keyword arguments for {Agent#initialize}.
      #
      # @option kwargs [Boolean] :visible (false)
      #   Controls whether the browser will start in visible or headless mode.
      #
      # @option kwargs [Boolean] headless (true)
      #   Controls whether the browser will start in headless or visible mode.
      #
      # @param [String, URI::HTTP, Addressible::URI, Hash, nil] proxy (Ronin::Support::Network::HTTP.proxy)
      #   The proxy to send all browser requests through.
      #
      # @return [Agent]
      #   A new instance of a headless or visible Chrome browser.
      #
      def self.new(**kwargs)
        Agent.new(**kwargs)
      end

      #
      # Opens a new browser.
      #
      # @yield [browser]
      #   If a block is given, it will be passed the new browser object.
      #   Once the block returns, `quit` will be called on the browser object.
      #
      # @yieldparam [Agent] browser
      #   The newly created browser object.
      #
      # @return [Agent]
      #   A new instance of a headless or visible Chrome browser.
      #
      def self.open(**kwargs,&block)
        Agent.open(**kwargs,&block)
      end
    end
  end
end
