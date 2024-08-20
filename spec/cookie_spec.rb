require 'spec_helper'
require 'ronin/web/browser/cookie'

describe Ronin::Web::Browser::Cookie do
  describe ".parse" do
    subject { described_class }

    context "when given an empty String" do
      let(:string) { '' }

      it do
        expect {
          subject.parse(string)
        }.to raise_error(ArgumentError,"cookie must not be empty: #{string.inspect}")
      end
    end

    context "when given a non-empty String" do
      let(:name)   { "foo" }
      let(:value)  { "bar" }

      context "when only given a 'name' String" do
        let(:string) { name }

        it "must return a #{described_class} with only the 'name' attribute" do
          cookie = subject.parse(string)

          expect(cookie).to be_kind_of(described_class)
          expect(cookie.name).to eq(name)
          expect(cookie.value).to be(nil)
        end
      end

      context "when only given a 'name=value' String" do
        let(:string) { "#{name}=#{value}" }

        it "must return a #{described_class} with the 'name' and 'value' attributes" do
          cookie = subject.parse(string)

          expect(cookie).to be_kind_of(described_class)
          expect(cookie.name).to eq(name)
          expect(cookie.value).to eq(value)
        end
      end

      context "when given a 'name=value; Expires=...' String" do
        let(:expires) { Time.at(1691287370) }
        let(:string)  { "#{name}=#{value}; Expires=#{expires.httpdate}" }

        it "must return a #{described_class} with the 'expires' attribute set to a UNIX timestamp" do
          cookie = subject.parse(string)

          expect(cookie).to be_kind_of(described_class)
          expect(cookie.name).to eq(name)
          expect(cookie.value).to eq(value)
          expect(cookie.expires).to eq(expires)
        end
      end

      context "when given a 'name=value; Path=...' String" do
        let(:path)   { '/' }
        let(:string) { "#{name}=#{value}; Path=#{path}" }

        it "must return a #{described_class} with the 'path' attribute set" do
          cookie = subject.parse(string)

          expect(cookie).to be_kind_of(described_class)
          expect(cookie.name).to eq(name)
          expect(cookie.value).to eq(value)
          expect(cookie.path).to eq(path)
        end
      end

      context "when given a 'name=value; Domain=...' String" do
        let(:domain) { 'example.com' }
        let(:string) { "#{name}=#{value}; Domain=#{domain}" }

        it "must return a #{described_class} with the 'domain' attribute set" do
          cookie = subject.parse(string)

          expect(cookie).to be_kind_of(described_class)
          expect(cookie.name).to eq(name)
          expect(cookie.value).to eq(value)
          expect(cookie.domain).to eq(domain)
        end
      end

      context "when given a 'name=value; SameSite=...' String" do
        let(:samesite) { 'Strict' }
        let(:string)   { "#{name}=#{value}; SameSite=#{samesite}" }

        it "must return a #{described_class} with the 'domain' attribute set" do
          cookie = subject.parse(string)

          expect(cookie).to be_kind_of(described_class)
          expect(cookie.name).to eq(name)
          expect(cookie.value).to eq(value)
          expect(cookie.samesite).to eq(samesite)
        end
      end

      context "when given a 'name=value; HttpOnly' String" do
        let(:string) { "#{name}=#{value}; HttpOnly" }

        it "must return a #{described_class} with the 'httpOnly' attribute set" do
          cookie = subject.parse(string)

          expect(cookie).to be_kind_of(described_class)
          expect(cookie.name).to eq(name)
          expect(cookie.value).to eq(value)
          expect(cookie.http_only?).to be(true)
        end
      end

      context "when given a 'name=value; Secure' String" do
        let(:string) { "#{name}=#{value}; Secure" }

        it "must return a #{described_class} with the 'secure' attribute set" do
          cookie = subject.parse(string)

          expect(cookie).to be_kind_of(described_class)
          expect(cookie.name).to eq(name)
          expect(cookie.value).to eq(value)
          expect(cookie.secure?).to be(true)
        end
      end

      context "when the String contains an unknown attribute" do
        let(:unknown_field) { "Foo=Bar" }
        let(:string)        { "#{name}=#{value}; #{unknown_field}" }

        it do
          expect {
            subject.parse(string)
          }.to raise_error(ArgumentError,"unrecognized Cookie field: #{unknown_field.inspect}")
        end
      end

      context "when the String contains an unknown flag" do
        let(:unknown_flag) { "Foo" }
        let(:string)       { "#{name}=#{value}; #{unknown_flag}" }

        it do
          expect {
            subject.parse(string)
          }.to raise_error(ArgumentError,"unrecognized Cookie flag: #{unknown_flag.inspect}")
        end
      end
    end
  end

  let(:attributes) do
    {
      "name"         => "OGP",
      "value"        => "-19027681:",
      "domain"       => ".google.com",
      "path"         => "/",
      "expires"      => 1691287370,
      "size"         => 13,
      "httpOnly"     => false,
      "secure"       => false,
      "session"      => false,
      "priority"     => "Medium",
      "sameParty"    => false,
      "sourceScheme" => "Secure",
      "sourcePort "  => 443
    }
  end

  subject { described_class.new(attributes) }
end
