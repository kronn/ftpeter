require 'spec_helper'

describe Ftpeter::CLI do
  it 'expects at least a hostname' do
    expect {
      described_class.new
    }.to raise_error ArgumentError
  end

  subject {
    described_class.new(["example.net"])
  }

  it 'has a godly go-method' do
    allow(subject).to receive(:okay?).and_return(false)

    $stdout = StringIO.new

    expect {
      subject.go
    }.to_not raise_error

    output = $stdout.string

    # the generated script
    expect(output).to match /!echo "Deployment complete"$/

    # information to user
    expect(output).to match /is left for your editing pleasure/
  end
end
