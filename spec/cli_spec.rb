require 'spec_helper'

describe Ftpeter::CLI do
  include FakeFS::SpecHelpers

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
    allow(subject).to receive(:get_changes_from).and_return(
      Ftpeter::CLI::Changes.new(
        [], #deleted
        ["lib/foo.rb"], #changed
        ["lib/new_foo.rb"], #added
        ["lib"], #newdirs
      )
    )

    $stdout = StringIO.new

    expect {
      subject.go
    }.to_not raise_error

    output = $stdout.string

    # the generated script
    expect(output).to match %r~^\={80}$
open example.net$
cd /$
mkdir -p lib
put lib/new_foo.rb -o lib/new_foo.rb
put lib/foo.rb -o lib/foo.rb
!echo ""$
!echo "Deployment complete"$
\={80}$~m

    # information to user
    expect(output).to match /is left for your editing pleasure/
  end

  context 'knows how to get changes' do
    it 'only for git (for now)' do
      expect {
        subject.get_changes_from(:svn)
      }.to raise_error(ArgumentError, "There's only git-support for now")
    end

    it 'by returning a Changes-object' do
      expect(subject.get_changes_from(:git)).to be_a Ftpeter::CLI::Changes
    end
  end
end

describe Ftpeter::CLI::Changes do
  it 'is a value-object' do
    expect(subject).to be_a Struct

    expect(subject).to respond_to :deleted
    expect(subject).to respond_to :changed
    expect(subject).to respond_to :added
    expect(subject).to respond_to :newdirs
  end
end
