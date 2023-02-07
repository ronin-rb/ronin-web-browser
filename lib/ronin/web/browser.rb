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

require 'ronin/support/network/http'

require 'ferrum'
require 'uri'

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
    # browser.network.intercept
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
    class Browser < Ferrum::Browser

      # The configured proxy information.
      #
      # @return [Hash{Symbol => Object}, nil]
      attr_reader :proxy

      #
      # Initializes the browser.
      #
      # @param [Boolean] visible
      #   Controls whether the browser will start in visible or headless mode.
      #
      # @param [Boolean] headless
      #   Controls whether the browser will start in headless or visible mode.
      #
      # @param [String, URI::HTTP, Addressible::URI, Hash, nil] proxy
      #   The proxy to send all browser requests through.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for `Ferrum::Browser#initialize`.
      #
      def initialize(visible:  false,
                     headless: !visible,
                     proxy:    Ronin::Support::Network::HTTP.proxy,
                     **kwargs)
        proxy = case proxy
                when Hash, nil then proxy
                when URI::HTTP, Addressable::URI
                  {
                    host:     proxy.host,
                    port:     proxy.port,
                    user:     proxy.user,
                    password: proxy.password
                  }
                when String
                  uri = URI(proxy)

                  {
                    host:     uri.host,
                    port:     uri.port,
                    user:     uri.user,
                    password: uri.password
                  }
                else
                  raise(ArgumentError,"invalid proxy value (#{proxy.inspect}), must be either a Hash, URI::HTTP, String, or nil")
                end

        @headless = headless
        @proxy    = proxy

        super(headless: headless, proxy: proxy, **kwargs)
      end

      #
      # Opens a new browser.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for {#initialize}.
      #
      # @yield [browser]
      #   If a block is given, it will be passed the new browser object.
      #   Once the block returns, `quit` will be called on the browser object.
      #
      # @yieldparam [Browser] browser
      #   The newly created browser object.
      #
      # @return [Browser]
      #   The opened browser object.
      #
      def self.open(**kwargs)
        browser = new(**kwargs)

        if block_given?
          yield browser
          browser.quit
        end

        return browser
      end

      #
      # Determines whether the browser was opened in headless mode.
      #
      # @return [Boolean]
      #
      def headless?
        @headless
      end

      #
      # Determines whether the browser was opened in visible mode.
      #
      # @return [Boolean]
      #
      def visible?
        !@headless
      end

      #
      # Determines whether the proxy was initialized with a proxy.
      #
      def proxy?
        !@proxy.nil?
      end

      #
      # Registers a callback for the given event type.
      #
      # @param [:request, :response, :dialog, String] event
      #   The event to register a callback for.
      #   For an exhaustive list of event String names, see the
      #   [Chrome DevTools Protocol documentation](https://chromedevtools.github.io/devtools-protocol/1-3/)
      #
      # @yield [request]
      #   If the event type is `:request` the given block will be passed the
      #   request object.
      #
      # @yield [exchange]
      #   If the event type is `:response` the given block will be passed the
      #   network exchange object containing both the request and the response
      #   objects.
      #
      # @yield [params, index, total]
      #   Other event types will be passed a params Hash, index, and total.
      #
      # @yieldparam [Ferrum::Network::Request] request
      #   A network request object.
      #
      # @yieldparam [Ferrum::Network::Exchange] exchange
      #   A network exchange object containing both the request and respoonse
      #   objects.
      #
      # @yieldparam [Hash{String => Object}] params
      #   A params Hash containing the return value(s).
      #
      # @yieldparam [Integer] index
      #
      # @yieldparam [Integer] total
      #
      def on(event,&block)
        case event
        when :response
          super('Network.responseReceived') do |params,index,total|
            response = browser.network.select(params['requestId']).last

            block.call(response,index,total)
          end
        else
          super(event,&block)
        end
      end

    end
  end
end
