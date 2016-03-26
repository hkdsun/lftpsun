require 'spec_helper'

describe Lftpsun do
  it 'has a version number' do
    expect(Lftpsun::VERSION).not_to be nil
  end

  it 'raises if no config' do
    expect {
      Lftpsun.config
    }.to raise_error(Lftpsun::NoConfigFound)
  end

  it 'doesnt raise if theres config' do
    Lftpsun.config = {}
    expect {
      Lftpsun.config
    }.not_to raise_error
  end
end
