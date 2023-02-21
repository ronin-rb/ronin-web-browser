require 'spec_helper'
require 'ronin/web/browser/agent'

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
end
