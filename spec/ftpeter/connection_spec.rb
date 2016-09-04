# frozen_string_literal: true
require 'spec_helper'
describe Ftpeter::Connection do
  it 'is a value-object' do
    expect(subject).to be_a Struct

    expect(subject).to respond_to :host
    expect(subject).to respond_to :credentials
    expect(subject).to respond_to :dir
    expect(subject).to respond_to :commands

    expect(subject).to respond_to :host=
    expect(subject).to respond_to :credentials=
    expect(subject).to respond_to :dir=
    expect(subject).to respond_to :commands=
  end
end
