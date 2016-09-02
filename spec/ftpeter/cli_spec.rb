require 'spec_helper'

describe Ftpeter::CLI do
  include FakeFS::SpecHelpers

  subject { described_class.new(["example.net"]) }

  # FIXME remove this once we don't parse netrc ourselves anymore
  before(:all) { FileUtils.touch("#{ENV['HOME']}/.netrc") }


  it 'expects at least a hostname' do
    expect {
      described_class.new
    }.to raise_error ArgumentError
  end

  it 'has a godly go-method' do
    expect(subject).to receive(:okay?).and_return(false)
    expect(subject).to receive(:get_changes_from).and_return(
      Ftpeter::Changes.new(
        [], #deleted
        ["lib/foo.rb"], #changed
        ["lib/new_foo.rb"], #added
      )
    )

    expected_script = <<-EOSCRIPT.lines.map { |l| "^#{l.tr("/", "\/")}$"}
open example.net
cd /
mkdir -p lib
put lib/new_foo.rb -o lib/new_foo.rb
put lib/foo.rb -o lib/foo.rb
!echo ""
!echo "Deployment complete"
    EOSCRIPT

    $stdout = StringIO.new

    expect {
      subject.go
    }.to_not raise_error

    output = $stdout.string

    # the generated script
    expect(Pathname.new('./lftp_script').expand_path.read).to match /#{expected_script}/

    # output of the script to the user
    expect(output).to match %r~^\={80}$#{expected_script}.*\={80}$~m

    # information to user
    expect(output).to match /is left for your editing pleasure/
  end

  it 'can take action' do
    expect(subject).to receive(:okay?).and_return(true)
    expect(subject).to receive(:get_changes_from).and_return(
      Ftpeter::Changes.new(
        [], #deleted
        ["lib/foo.rb"], #changed
        ["lib/new_foo.rb"], #added
      )
    )
    expect_any_instance_of(Ftpeter::Transport::Lftp)
      .to receive(:execute)
      .and_return(true)

    expected_script = <<-EOSCRIPT.lines.map { |l| "^#{l.tr("/", "\/")}$"}
open example.net
cd /
mkdir -p lib
put lib/new_foo.rb -o lib/new_foo.rb
put lib/foo.rb -o lib/foo.rb
!echo ""
!echo "Deployment complete"
    EOSCRIPT

    $stdout = StringIO.new

    expect {
      subject.go
    }.to_not raise_error

    output = $stdout.string

    # output of the script to the user
    expect(output).to match %r~^\={80}$#{expected_script}.*\={80}$~m

    # the generated script is cleaned up
    expect(Pathname.new('./lftp_script').expand_path).to_not be_readable
    expect(output).to_not match /is left for your editing pleasure/
  end

  context 'knows how to get changes' do
    it 'only for git (for now)' do
      expect {
        subject.get_changes_from(:svn)
      }.to raise_error(ArgumentError, "There's only git-support for now")
    end

    it 'by returning a Changes-object' do
      expect(subject.get_changes_from(:git)).to be_a Ftpeter::Changes
    end
  end

  context 'knows how to transport changes' do
    it 'with a proxy-object' do
      expect(subject.transport(double(:changes))).to be_a Ftpeter::Transport
    end
  end
end
