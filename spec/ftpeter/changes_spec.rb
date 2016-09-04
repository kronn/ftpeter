# frozen_string_literal: true
require 'spec_helper'
describe Ftpeter::Changes do
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
