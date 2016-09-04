require 'spec_helper'

describe Ftpeter::Transport::Lftp do
  subject { described_class.new(connection, changes) }
  let(:changes) do
    Ftpeter::Changes.new(
      [], # deleted
      ["lib/foo.rb"], # changed
      ["lib/new_foo.rb"], # added
    )
  end
  let(:connection) do
    Ftpeter::Connection.new("example.net", nil, "/", nil)
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

  it 'writes and executes the script' do
    expect(subject).to receive(:system)
      .with("lftp -f #{subject.script}")

    expect(subject.script).to receive(:open)
      .with('w')

    expect {
      subject.persist
      subject.execute
    }.to_not raise_error
  end

  it 'outputs the script' do
    expect(subject.inform).to be_a String
    expect(subject.inform).to match /open.*cd.*mkdir.*put/m
  end

  it 'cleans up any residual files' do
    expect(subject.script).to receive(:delete)
    expect { subject.cleanup }.to_not raise_error
  end
end
