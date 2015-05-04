require_relative 'spec_helper'

describe 'Credit Card APP Secure' do
  describe 'Getting the root of the service' do
    it 'should return ok' do
      get '/'
      last_response.body.must_include 'APP Running and Working'
      last_response.status.must_equal 200
    end
  end

end
