require 'spec_helper'
require 'ronin/web/browser/agent'

require 'tempfile'

describe Ronin::Web::Browser::Agent do
  describe "#initialize" do
    context "when Ronin::Support::Network::HTTP.proxy is set" do
      let(:proxy_host) { 'example.com' }
      let(:proxy_port) { 8080 }
      let(:proxy_uri)  { URI::HTTP.build(host: proxy_host, port: proxy_port) }

      before { Ronin::Support::Network::HTTP.proxy = proxy_uri }

      it "must use Ronin::Support::Network::HTTP.proxy and set #proxy" do
        expect(subject.proxy).to be_kind_of(Hash)
        expect(subject.proxy[:host]).to eq(proxy_host)
        expect(subject.proxy[:port]).to eq(proxy_port)
      end

      after { Ronin::Support::Network::HTTP.proxy = nil }
    end

    context "when given the proxy: keyword argument" do
      let(:proxy_host) { 'example.com' }
      let(:proxy_port) { 8080 }

      context "and it's an Addressable::URI" do
        let(:proxy) { Addressable::URI.new(host: proxy_host, port: proxy_port) }

        subject { described_class.new(proxy: proxy) }

        it "must convert it to a Hash object" do
          expect(subject.proxy).to be_kind_of(Hash)
          expect(subject.proxy[:host]).to eq(proxy_host)
          expect(subject.proxy[:port]).to eq(proxy_port)
        end
      end

      context "and it's an URI::HTTP" do
        let(:proxy) { URI::HTTP.build(host: proxy_host, port: proxy_port) }

        subject { described_class.new(proxy: proxy) }

        it "must convert it to a Hash object" do
          expect(subject.proxy).to be_kind_of(Hash)
          expect(subject.proxy[:host]).to eq(proxy_host)
          expect(subject.proxy[:port]).to eq(proxy_port)
        end
      end

      context "and it's a Hash" do
        let(:proxy) do
          {host: proxy_host, port: proxy_port}
        end

        subject { described_class.new(proxy: proxy) }

        it "must convert it to a Hash object" do
          expect(subject.proxy).to be_kind_of(Hash)
          expect(subject.proxy[:host]).to eq(proxy_host)
          expect(subject.proxy[:port]).to eq(proxy_port)
        end
      end

      context "and it's a String" do
        let(:proxy) { "http://#{proxy_host}:#{proxy_port}" }

        subject { described_class.new(proxy: proxy) }

        it "must convert it to a Hash object" do
          expect(subject.proxy).to be_kind_of(Hash)
          expect(subject.proxy[:host]).to eq(proxy_host)
          expect(subject.proxy[:port]).to eq(proxy_port)
        end
      end
    end

    after { subject.quit }
  end

  describe ".open" do
    subject { described_class }

    context "when given a block" do
      it "must yield a new #{described_class} instance" do
        expect { |b|
          subject.open(&b)
        }.to yield_successive_args(described_class)
      end
    end

    context "when no block is given" do
      it "must return a #{described_class}" do
        browser = subject.open

        expect(browser).to be_kind_of(described_class)
        browser.quit
      end
    end
  end

  describe "#headless?" do
    it "must default to true" do
      expect(subject.headless?).to be(true)
    end

    after { subject.quit }
  end

  describe "#visible?" do
    it "must default to false" do
      expect(subject.visible?).to be(false)
    end

    after { subject.quit }
  end

  describe "#proxy?" do
    context "when #proxy is set" do
      let(:proxy_host) { 'example.com' }
      let(:proxy_port) { 8080 }
      let(:proxy) do
        {host: proxy_host, port: proxy_port}
      end

      subject { described_class.new(proxy: proxy) }

      it "must return true" do
        expect(subject.proxy?).to be(true)
      end
    end

    context "when #proxy is not set" do
      it "must return false" do
        expect(subject.proxy?).to be(false)
      end
    end

    after { subject.quit }
  end

  describe "#bypass_csp=" do
    context "when given true" do
      before { subject.bypass_csp = true }

      it "must enable #bypass_csp" do
        expect(subject.bypass_csp).to be(true)
      end
    end

    after { subject.quit }
  end

  describe "#each_session_cookie" do
    context "when there are session cookies" do
      let(:name1)   { 'rack.session' }
      let(:value1)  { 'BAh7CEkiD3Nlc3Npb25faWQGOgZFVG86HVJhY2s6OlNlc3Npb246OlNlc3Npb25JZAY6D0BwdWJsaWNfaWRJIkUyYWJkZTdkM2I0YTMxNDE5OThiYmMyYTE0YjFmMTZlNTNlMWMzYWJlYzhiYzc4ZjVhMGFlMGUwODJmMjJlZGIxBjsARkkiCWNzcmYGOwBGSSIxNHY1TmRCMGRVaklXdjhzR3J1b2ZhM2xwNHQyVGp5ZHptckQycjJRWXpIZz0GOwBGSSINdHJhY2tpbmcGOwBGewZJIhRIVFRQX1VTRVJfQUdFTlQGOwBUSSItOTkxNzUyMWYzN2M4ODJkNDIyMzhmYmI5Yzg4MzFmMWVmNTAwNGQyYwY7AEY%3D--02184e43850f38a46c8f22ffb49f7f22be58e272' }
      let(:domain1) { 'rails-app.com' }

      let(:name2)   { '_foo_sess' }
      let(:value2)  { 'eyJmb28iOiJiYXIifQ:1pQcTx:UufiSnuPIjNs7zOAJS0UpqnyvRt7KET7BVes0I8LYbA' }
      let(:domain2) { 'foo-app.com' }

      before do
        subject.cookies.set(name: name1, value: value1, domain: domain1, session: true)
        subject.cookies.set(name: name2, value: value2, domain: domain2, session: true)
      end

      context "when a block is given" do
        it "must yield each session cookie" do
          yielded_cookies = []

          subject.each_session_cookie do |cookie|
            yielded_cookies << cookie
          end

          expect(yielded_cookies).to all(be_kind_of(Ferrum::Cookies::Cookie))
          expect(yielded_cookies.length).to eq(2)
          expect(yielded_cookies[0].name).to eq(name1)
          expect(yielded_cookies[0].value).to eq(value1)
          expect(yielded_cookies[0].domain).to eq(domain1)
          expect(yielded_cookies[0].session?).to be(true)

          expect(yielded_cookies[1].name).to eq(name2)
          expect(yielded_cookies[1].value).to eq(value2)
          expect(yielded_cookies[1].domain).to eq(domain2)
          expect(yielded_cookies[1].session?).to be(true)
        end
      end
    end

    context "when no session cookie is set" do
      context "when a block is given" do
        it "must not yield any cookies" do
          expect { |b|
            subject.each_session_cookie(&b)
          }.to_not yield_control
        end
      end
    end

    after { subject.quit }
  end

  describe "#session_cookies" do
    let(:name1)   { 'rack.session' }
    let(:value1)  { 'BAh7CEkiD3Nlc3Npb25faWQGOgZFVG86HVJhY2s6OlNlc3Npb246OlNlc3Npb25JZAY6D0BwdWJsaWNfaWRJIkUyYWJkZTdkM2I0YTMxNDE5OThiYmMyYTE0YjFmMTZlNTNlMWMzYWJlYzhiYzc4ZjVhMGFlMGUwODJmMjJlZGIxBjsARkkiCWNzcmYGOwBGSSIxNHY1TmRCMGRVaklXdjhzR3J1b2ZhM2xwNHQyVGp5ZHptckQycjJRWXpIZz0GOwBGSSINdHJhY2tpbmcGOwBGewZJIhRIVFRQX1VTRVJfQUdFTlQGOwBUSSItOTkxNzUyMWYzN2M4ODJkNDIyMzhmYmI5Yzg4MzFmMWVmNTAwNGQyYwY7AEY%3D--02184e43850f38a46c8f22ffb49f7f22be58e272' }
    let(:domain1) { 'rails-app.com' }

    let(:name2)   { '_foo_sess' }
    let(:value2)  { 'eyJmb28iOiJiYXIifQ:1pQcTx:UufiSnuPIjNs7zOAJS0UpqnyvRt7KET7BVes0I8LYbA' }
    let(:domain2) { 'foo-app.com' }

    before do
      subject.cookies.set(name: name1, value: value1, domain: domain1, session: true)
      subject.cookies.set(name: name2, value: value2, domain: domain2, session: true)
    end

    it "must return an Array of session cookies" do
      session_cookies = subject.session_cookies

      expect(session_cookies).to be_kind_of(Array)
      expect(session_cookies.length).to eq(2)
      expect(session_cookies).to all(be_kind_of(Ferrum::Cookies::Cookie))
      expect(session_cookies[0].name).to eq(name1)
      expect(session_cookies[0].value).to eq(value1)
      expect(session_cookies[0].domain).to eq(domain1)
      expect(session_cookies[0].session?).to be(true)

      expect(session_cookies[1].name).to eq(name2)
      expect(session_cookies[1].value).to eq(value2)
      expect(session_cookies[1].domain).to eq(domain2)
      expect(session_cookies[1].session?).to be(true)
    end

    after { subject.quit }
  end

  describe "#set_cookie" do
    let(:name)   { 'foo' }
    let(:value)  { 'bar' }
    let(:domain) { 'example.com' }

    before do
      subject.set_cookie(name,value, domain: domain)
    end

    it "must set the cookie with the given name and value, and additional options" do
      cookie = subject.cookies[name]

      expect(cookie).to be_kind_of(Ferrum::Cookies::Cookie)
      expect(cookie.name).to eq(name)
      expect(cookie.value).to eq(value)
      expect(cookie.domain).to eq(domain)
    end

    after { subject.quit }
  end

  let(:fixtures_dir) { File.join(__dir__,'fixtures') }

  describe "#load_cookies" do
    let(:cookie_file) { File.join(fixtures_dir,'cookies.txt') }

    before { subject.load_cookies(cookie_file) }

    it "must parse and load all cookies from the cookie file" do
      cookies = subject.cookies.to_a

      expect(cookies).to all(be_kind_of(Ferrum::Cookies::Cookie))
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

    after { subject.quit }
  end

  describe "#save_cookies" do
    let(:tempfile)    { Tempfile.new }
    let(:output_path) { tempfile.path }

    before do
      subject.cookies.set(name: 'foo', value: 'bar', domain: 'example.com', secure: true)
      subject.cookies.set(name: 'baz', value: 'qux', domain: 'other.com', http_only: true)

      subject.save_cookies(output_path)
    end

    it "must write all cookies to the output file" do
      cookies = File.readlines(output_path, chomp: true)

      expect(cookies.length).to eq(2)
      expect(cookies[0]).to match(%r{\Afoo=bar; Domain=example.com; Path=/; Expires=[^;]+; Secure\z})
      expect(cookies[1]).to match(%r{\Abaz=qux; Domain=other.com; Path=/; Expires=[^;]+\z})
    end

    after { subject.quit }
  end
end
