require 'spec_helper'
require 'ronin/web/browser/cookie_file'

describe Ronin::Web::Browser::CookieFile do
  let(:fixtures_dir) { File.join(__dir__,'fixtures') }
  let(:path)         { File.join(fixtures_dir,'cookies.txt') }

  subject { described_class.new(path) }

  describe "#initialize" do
    it "must set #path" do
      expect(subject.path).to eq(path)
    end

    context "when given a relative path" do
      let(:relative_path) { File.join(__FILE__,'..','fixtures','cookies.txt') }

      subject { described_class.new(relative_path) }

      it "must expand the path" do
        expect(subject.path).to eq(path)
      end
    end
  end

  describe ".save"

  describe "#each" do
    context "when given a block" do
      it "must parse each line of the cookie file and yield Ronin::Web::Browser::Cookie objects" do
        yielded_cookies = []

        subject.each do |cookie|
          yielded_cookies << cookie
        end

        expect(yielded_cookies).to all(be_kind_of(Ronin::Web::Browser::Cookie))
        expect(yielded_cookies.length).to eq(2)
        expect(yielded_cookies[0].name).to eq('foo')
        expect(yielded_cookies[0].value).to eq('bar')
        expect(yielded_cookies[0].domain).to eq('example.com')
        expect(yielded_cookies[0].secure?).to be(true)

        expect(yielded_cookies[1].name).to eq('baz')
        expect(yielded_cookies[1].value).to eq('qux')
        expect(yielded_cookies[1].domain).to eq('other.com')
        expect(yielded_cookies[1].http_only?).to be(true)
      end
    end

    context "when no block is given" do
      it "must return an Enumerator object for the method" do
        cookies = subject.each.to_a

        expect(cookies).to all(be_kind_of(Ronin::Web::Browser::Cookie))
        expect(cookies.length).to eq(2)
        expect(cookies[0].name).to eq('foo')
        expect(cookies[0].value).to eq('bar')
        expect(cookies[0].domain).to eq('example.com')
        expect(cookies[0].secure?).to be(true)

        expect(cookies[1].name).to eq('baz')
        expect(cookies[1].value).to eq('qux')
        expect(cookies[1].domain).to eq('other.com')
        expect(cookies[1].http_only?).to be(true)
      end
    end
  end
end
