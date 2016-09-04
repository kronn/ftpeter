# frozen_string_literal: true
require 'spec_helper'

describe Ftpeter::Transport do
  subject { described_class.new(changes) }
  let(:changes) do
    Ftpeter::Changes.new(
      [], # deleted
      ['lib/foo.rb'], # changed
      ['lib/new_foo.rb'], # added
    )
  end
  let(:connection) do
    Struct.new(:host, :credentials, :dir, :commands)
      .new('example.net', nil, '/', nil)
  end

  it 'can forward the transport to a backend' do
    expect(subject).to respond_to :via
  end

  it 'only for lftp (for now)' do
    expect {
      subject.via(connection, :cyberduck)
    }.to raise_error(Ftpeter::Transport::Unsupported)
  end

  it 'by returning a concrete Transport-object' do
    expect(subject.via(connection, :lftp)).to be_a Ftpeter::Transport::Lftp
  end
end
