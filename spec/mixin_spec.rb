require 'spec_helper'
require 'ronin/web/browser/mixin'

describe Ronin::Web::Browser::Mixin do
  subject do
    obj = Object.new
    obj.extend described_class
    obj
  end

  describe "#browser" do
    context "when called for the first time" do
      context "without keyword arguments" do
        it "must initialize a new Ronin::Web::Browser::Agent object" do
          expect(subject.browser).to be_kind_of(Ronin::Web::Browser::Agent)
        end
      end

      context "with keyword arguments" do
        it "must initialize a new Ronin::Web::Browser::Agent object" do
          new_browser = subject.browser(
            cookie: {name: 'foo', value: 'bar', domain: 'example.com'}
          )

          expect(new_browser).to be_kind_of(Ronin::Web::Browser::Agent)
          expect(new_browser.cookies['foo']).to_not be(nil)
        end
      end
    end

    context "when called for the second time" do
      context "without keyword arguments" do
        it "must return the previously initialized browser object" do
          previous_browser = subject.browser
          new_browser      = subject.browser

          expect(new_browser).to be(previous_browser)
        end
      end

      context "with keyword arguments" do
        it "must initialize a new Ronin::Web::Browser::Agent object" do
          previous_browser = subject.browser
          new_browser      = subject.browser(
            cookie: {name: 'foo', value: 'bar', domain: 'example.com'}
          )

          expect(new_browser).to_not be(previous_browser)
          expect(new_browser).to be_kind_of(Ronin::Web::Browser::Agent)
          expect(new_browser.cookies['foo']).to_not be(nil)
        end
      end
    end
  end
end
