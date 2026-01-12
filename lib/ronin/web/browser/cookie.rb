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

require 'ferrum/cookies/cookie'

module Ronin
  module Web
    module Browser
      #
      # Represents a browser cookie.
      #
      class Cookie < Ferrum::Cookies::Cookie

        #
        # Parses a browser cookie from a raw String.
        #
        # @param [String] string
        #   The raw cookie String to parse.
        #
        # @return [Cookie]
        #   The parsed cookie.
        #
        # @raise [ArgumentError]
        #   The string was empty or contains an unknown field.
        #
        def self.parse(string)
          fields = string.split(/;\s+/)

          if fields.empty?
            raise(ArgumentError,"cookie must not be empty: #{string.inspect}")
          end

          name, value = fields.shift.split('=',2)
          attributes  = {
            'name'  => name,
            'value' => value
          }

          fields.each do |field|
            if field.include?('=')
              key, value = field.split('=',2)

              case key
              when 'Expires', 'Max-Age'
                attributes['expires'] = Time.parse(value).to_i
              when 'Path'    then attributes['path']     = value
              when 'Domain'  then attributes['domain']   = value
              when 'SameSite'then attributes['sameSite'] = value
              else
                raise(ArgumentError,"unrecognized Cookie field: #{field.inspect}")
              end
            else
              case field
              when 'HttpOnly' then attributes['httpOnly'] = true
              when 'Secure'   then attributes['secure']   = true
              else
                raise(ArgumentError,"unrecognized Cookie flag: #{field.inspect}")
              end
            end
          end

          return new(attributes)
        end

        #
        # The priority of the cookie.
        #
        # @return [String]
        #
        def priority
          @attributes['priority']
        end

        #
        # @return [Boolean]
        #
        def sameparty?
          @attributes['sameParty']
        end

        alias same_party? sameparty?

        #
        # @return [String]
        #
        def source_scheme
          @attributes['sourceScheme']
        end

        #
        # @return [Integer]
        #
        def source_port
          @attributes['sourcePort']
        end

        #
        # Converts the cookie back into a raw cookie String.
        #
        # @return [String]
        #   The raw cookie string.
        #
        def to_s
          string = "#{@attributes['name']}=#{@attributes['value']}"

          @attributes.each do |key,value|
            case key
            when 'name', 'value' # no-op
            when 'domain'   then string << "; Domain=#{value}"
            when 'path'     then string << "; Path=#{value}"
            when 'expires'  then string << "; Expires=#{Time.at(value).httpdate}"
            when 'httpOnly' then string << "; httpOnly" if value
            when 'secure'   then string << "; Secure"   if value
            end
          end

          return string
        end

      end
    end
  end
end
