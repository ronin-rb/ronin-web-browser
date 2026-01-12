# frozen_string_literal: true
#
# ronin-web-browser - An automated Chrome API.
#
# Copyright (c) 2022-2026 Hal Brodigan (postmodern.mod3@gmail.com)
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

module Ronin
  module Web
    module Browser
      #
      # Mixin methods for interacting with a Chrome browser.
      #
      # @since 0.2.0
      #
      module Mixin
        #
        # Initializes or returns a browser instance.
        #
        # @param [Hash{Symbol => Object}] kwargs
        #   If no keyword arguments are given, then the previously initialized
        #   browser will be returned. If keyword arguments are given, then a new
        #   browser will be initialized with them.
        #
        # @option kwargs [Boolean] :visible (false)
        #   Controls whether the browser will start in visible or headless mode.
        #
        # @option kwargs [Boolean] :headless (true)
        #   Controls whether the browser will start in headless or visible mode.
        #
        # @option kwargs [Hash{Symbol => Object}, Ferrum::Cookies::Cookie, nil] :cookie
        #   Provides cookie to set for browser after initialization.
        #
        # @option kwargs [String, nil] :url
        #   Provides url for browser to navigate to after initialization.
        #
        # @option kwargs [String, URI::HTTP, Addressible::URI, Hash, nil] :proxy (Ronin::Support::Network::HTTP.proxy)
        #   The proxy to send all browser requests through.
        #
        # @return [Agent]
        #   The browser instance.
        #
        # @example
        #   browser(url: 'https://example.com')
        #   browser.goto('https://google.com')
        #
        # @api public
        #
        # @see Agent#initialize
        #
        def browser(**kwargs)
          if kwargs.empty?
            @browser ||= Agent.new(**kwargs)
          else
            @browser = Agent.new(**kwargs)
          end
        end
      end
    end
  end
end
