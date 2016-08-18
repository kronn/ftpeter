require 'spec_helper'

describe Ftpeter::CLI do
  it 'expects at least a hostname' do
    expect {
      described_class.new
    }.to raise_error ArgumentError
  end
end
