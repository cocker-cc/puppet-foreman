require 'spec_helper'

describe 'foreman::plugin::supervisory_authority' do
  context 'with Standard-Parameters' do
    let(:params) do
      {
        'server_url'   => 'https://example.com',
        'secret_token' => 'secret_example',
        'service_name' => 'foreman prod',
      }
    end
    include_examples 'basic foreman plugin tests', 'supervisory_authority'
  end
  context 'with Sensitive secret_token' do
    let(:params) do
      {
        'server_url'   => 'https://example.com',
        'secret_token' => sensitive('secret_example'),
        'service_name' => 'foreman prod',
      }
    end
    include_examples 'basic foreman plugin tests', 'supervisory_authority'
  end
end
