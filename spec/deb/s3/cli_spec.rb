# -*- encoding : utf-8 -*-
require File.expand_path('../../../spec_helper', __FILE__)
require 'deb/s3/cli'

describe Deb::S3::CLI do
  def base_options(overrides = {})
    {
      :bucket => "test-bucket",
      :s3_region => "us-east-1",
      :proxy_uri => nil,
      :force_path_style => false,
      :endpoint => nil,
      :access_key_id => nil,
      :secret_access_key => nil,
      :session_token => nil,
      :sign => nil,
      :gpg_provider => "gpg",
      :gpg_options => "",
      :prefix => nil,
      :encryption => false,
      :visibility => "public",
      :checksum_when_required => false,
    }.merge(overrides)
  end

  describe "#configure_s3_client" do
    it "configures request checksum calculation when checksum_when_required is enabled" do
      cli = Deb::S3::CLI.new
      captured_settings = nil
      fake_client = Object.new

      cli.stub :options, base_options(:checksum_when_required => true) do
        Aws::S3::Client.stub :new, lambda { |settings|
          captured_settings = settings
          fake_client
        } do
          cli.send(:configure_s3_client)
        end
      end

      _(captured_settings[:request_checksum_calculation]).must_equal "when_required"
      _(Deb::S3::Utils.s3).must_equal fake_client
    end

    it "does not override request checksum calculation by default" do
      cli = Deb::S3::CLI.new
      captured_settings = nil

      cli.stub :options, base_options do
        Aws::S3::Client.stub :new, lambda { |settings|
          captured_settings = settings
          Object.new
        } do
          cli.send(:configure_s3_client)
        end
      end

      _(captured_settings.key?(:request_checksum_calculation)).must_equal false
    end
  end
end
