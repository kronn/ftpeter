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
    allow(subject).to receive(:okay?).and_return(false)
    allow(subject).to receive(:get_changes_from).and_return(
      Ftpeter::Backend::Changes.new(
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
    expect(Pathname.new('./lftp_script').read).to match /#{expected_script}/

    # output of the script to the user
    expect(output).to match %r~^\={80}$#{expected_script}.*\={80}$~m

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
      expect(subject.get_changes_from(:git)).to be_a Ftpeter::Backend::Changes
    end
  end

  context 'knows how to transport changes' do
    it 'with a proxy-object' do
      expect(subject.transport(double(:changes))).to be_a Ftpeter::Transport
    end
  end
end

describe Ftpeter::Backend::Changes do
  it 'is a value-object' do
    expect(subject).to be_a Struct

    expect(subject).to respond_to :deleted
    expect(subject).to respond_to :changed
    expect(subject).to respond_to :added
    expect(subject).to respond_to :newdirs

    expect(subject).to respond_to :deleted=
    expect(subject).to respond_to :changed=
    expect(subject).to respond_to :added=
    expect(subject).to_not respond_to :newdirs=
  end

  it 'can calculate the needed new directories' do
    expect(described_class.new([], ['lib/changed.rb'], ['lib/new.rb']).newdirs)
      .to eq ['lib']
  end
end

describe Ftpeter::Transport do
  subject { described_class.new(changes) }
  let(:changes) do
    Ftpeter::Backend::Changes.new(
      [], #deleted
      ["lib/foo.rb"], #changed
      ["lib/new_foo.rb"], #added
    )
  end
  let(:connection) do
    Struct.new(:host, :credentials, :dir, :commands)
      .new("example.net", nil, "/", nil)
  end

  it 'can forward the transport to a backend' do
    expect(subject).to respond_to :via
  end

  it 'only for lftp (for now)' do
    expect {
      subject.via(connection, :cyberduck)
    }.to raise_error(ArgumentError, "There's only lftp-support for now")
  end

  it 'by returning a concrete Transport-object' do
    expect(subject.via(connection, :lftp)).to be_a Ftpeter::Transport::Lftp
  end
end

describe Ftpeter::Transport::Lftp do
  subject{ described_class.new(connection, changes) }
  let(:changes) do
    Ftpeter::Backend::Changes.new(
      [], #deleted
      ["lib/foo.rb"], #changed
      ["lib/new_foo.rb"], #added
    )
  end
  let(:connection) do
    Struct.new(:host, :credentials, :dir, :commands)
      .new("example.net", nil, "/", nil)
  end

  it 'generates a set of commands' do
    expected_script = <<-EOSCRIPT.lines.map { |l| l.chomp }
open example.net
cd /
mkdir -p lib
put lib/new_foo.rb -o lib/new_foo.rb
put lib/foo.rb -o lib/foo.rb
!echo ""
!echo "Deployment complete"
    EOSCRIPT

    expect(subject.commands).to eql expected_script
  end

  it 'writes the script to a file'
  it 'executes the script'
  it 'outputs the script'
end
