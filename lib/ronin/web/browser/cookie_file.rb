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

module Ronin
  module Web
    module Browser
      #
      # Represents a file of cookies.
      #
      class CookieFile

        include Enumerable

        # The path to the file.
        #
        # @return [String]
        attr_reader :path

        #
        # Initializes a cookie file.
        #
        # @param [String] path
        #   The path to the cookie file.
        #
        def initialize(path)
          @path = File.expand_path(path)
        end

        #
        # Writes the cookies to the cookie file.
        #
        # @param [String] path
        #   The path to the cookie file to write to.
        #
        # @param [Array<Cookie>, Enumerator<Cookie>] cookies
        #   The cookies to write.
        #
        def self.save(path,cookies)
          File.open(path,'w') do |file|
            cookies.each do |cookie|
              file.puts(cookie)
            end
          end
        end

        #
        # Parses each cookie in the cookie file.
        #
        # @yield [cookie]
        #   The given block will be passed each cookie parsed from each line of
        #   the file.
        #
        # @yieldparam [Cookie] cookie
        #   A cookie parsed from the file.
        #
        # @return [Enumerator]
        #   If no block is given, then an Enumerator will be returned.
        #
        def each
          return enum_for(__method__) unless block_given?

          File.open(@path) do |file|
            file.each_line(chomp: true) do |line|
              yield Cookie.parse(line)
            end
          end
        end

      end
    end
  end
end
