# frozen_string_literal: true
#
# ronin-web-browser - An automated Chrome API.
#
# Copyright (c) 2022-2024 Hal Brodigan (postmodern.mod3@gmail.com)
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

require_relative 'cookie'
require_relative 'cookie_file'

require 'ronin/support/network/http'
require 'ferrum'
require 'uri'

module Ronin
  module Web
    module Browser
      #
      # Represents an instance of a Chrome headless or visible browser.
      #
      class Agent < Ferrum::Browser

        # The configured proxy information.
        #
        # @return [Hash{Symbol => Object}, nil]
        attr_reader :proxy

        #
        # Initializes the browser agent.
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
        # @yieldparam [Agent] browser
        #   The newly created browser object.
        #
        # @return [Agent]
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
        # Enables or disables bypassing CSP.
        #
        # @param [Boolean] mode
        #   Controls whether to enable or disable CSP bypassing.
        #
        def bypass_csp=(mode)
          if mode then bypass_csp(enabled: true)
          else         bypass_csp(enabled: false)
          end
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
        # @yieldparam [Ferrum::Network::InterceptedRequest] request
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
              exchange = network.select(params['requestId']).last

              if exchange
                block.call(exchange,index,total)
              end
            end
          when :close
            super('Inspector.detached',&block)
          else
            super(event,&block)
          end
        end

        #
        # Passes every request to the given block.
        #
        # @yield [request]
        #   The given block will be passed each request before it's sent.
        #
        # @yieldparam [Ferrum::Network::InterceptRequest] request
        #   A network request object.
        #
        def every_request
          network.intercept

          on(:request) do |request|
            yield request
            request.continue
          end
        end

        #
        # Passes every response to the given block.
        #
        # @yield [response]
        #   If the given block accepts a single argument, it will be passed
        #   each response object.
        #
        # @yield [response, request]
        #   If the given block accepts two arguments, it will be passed the
        #   response and the request objects.
        #
        # @yieldparam [Ferrum::Network::Response] response
        #   A respone object returned for a request.
        #
        # @yieldparam [Ferrum::Network::Request] request
        #   The request object for the response.
        #
        def every_response(&block)
          on(:response) do |exchange,index,total|
            if block.arity == 2
              yield exchange.response, exchange.request
            else
              yield exchange.response
            end
          end
        end

        #
        # Passes every requested URL to the given block.
        #
        # @yield [url]
        #   The given block will be passed every URL.
        #
        # @yieldparam [String] url
        #   A URL requested by the browser.
        #
        def every_url
          every_request do |request|
            yield request.url
          end
        end

        #
        # Passes every requested URL that matches the given pattern to the given
        # block.
        #
        # @param [String, Regexp] pattern
        #   The pattern to filter the URLs by.
        #
        # @yield [url]
        #   The given block will be passed every URL that matches the pattern.
        #
        # @yieldparam [String] url
        #   A matching URL requested by the browser.
        #
        def every_url_like(pattern)
          every_url do |url|
            if pattern.match(url)
              yield url
            end
          end
        end

        #
        # The page's current URI.
        #
        # @return [URI::HTTP]
        #
        def page_uri
          URI.parse(url)
        end

        #
        # Queries the XPath or CSS-path query and returns the matching nodes.
        #
        # @return [Array<Ferrum::Node>]
        #   The matching node.
        #
        def search(query)
          if query.start_with?('/')
            xpath(query)
          else
            css(query)
          end
        end

        #
        # Queries the XPath or CSS-path query and returns the first match.
        #
        # @return [Ferrum::Node, nil]
        #   The first matching node.
        #
        def at(query)
          if query.start_with?('/')
            at_xpath(query)
          else
            at_css(query)
          end
        end

        #
        # Queries all `<a href="...">` links in the current page.
        #
        # @return [Array<String>]
        #
        def links
          xpath('//a/@href').map(&:value)
        end

        #
        # All link URLs in the current page.
        #
        # @return [Array<URI::HTTP, URI::HTTPS>]
        #
        def urls
          page_uri = self.page_uri

          links.map { |link| page_uri.merge(link) }
        end

        alias eval_js evaluate
        alias load_js add_script_tag
        alias inject_js evaluate_on_new_document
        alias load_css add_style_tag

        #
        # Enumerates over all session cookies.
        #
        # @yield [cookie]
        #   The given block will be passed each session cookie.
        #
        # @yieldparam [Ferrum::Cookies::Cookie] cookie
        #   A cookie that ends with `sess` or `session`.
        #
        # @return [Enumerator]
        #   If no block is given, then an Enumerator object will be returned.
        #
        def each_session_cookie
          return enum_for(__method__) unless block_given?

          cookies.each do |cookie|
            yield cookie if cookie.session?
          end
        end

        #
        # Fetches all session cookies.
        #
        # @return [Array<Ferrum::Cookie>]
        #   The matching session cookies.
        #
        def session_cookies
          each_session_cookie.to_a
        end

        #
        # Sets a cookie.
        #
        # @param [String] name
        #   The cookie name.
        #
        # @param [String] value
        #   The cookie value.
        #
        # @param [Hash{Symbol => Object}] options
        #   Additional cookie attributes.
        #
        def set_cookie(name,value,**options)
          cookies.set(name: name, value: value, **options)
        end

        #
        # Loads the cookies from the cookie file.
        #
        # @param [String] path
        #   The path to the cookie file.
        #
        def load_cookies(path)
          CookieFile.new(path).each do |cookie|
            cookies.set(cookie)
          end
        end

        #
        # Saves the cookies to a cookie file.
        #
        # @param [String] path
        #   The path to the output cookie file.
        #
        def save_cookies(path)
          CookieFile.save(path,cookies)
        end

        #
        # Waits indefinitely until the browser window is closed.
        #
        def wait_until_closed
          window_closed = false

          on('Inspector.detached') do
            window_closed = true
          end

          sleep(1) until window_closed
        end

      end
    end
  end
end
