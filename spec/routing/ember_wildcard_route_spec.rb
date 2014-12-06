require 'spec_helper'
require 'securerandom'

describe 'ember wildcard route' do
  let(:route) { SecureRandom.hex(16) }

  it 'routes to static#app' do
    expect(get route).to route_to(
      controller: 'static',
      action: 'app',
      ember: route # see note below
    )
  end
end
