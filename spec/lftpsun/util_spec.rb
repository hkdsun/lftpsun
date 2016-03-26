require 'spec_helper'

describe Lftpsun do
  it 'authorized should return true for the correct secret' do
    expect(Lftpsun.authorized?('test_secret')).to be(true)
  end

  it 'authorized returns false' do
    expect(Lftpsun.authorized?('no_the_secret')).to be(false)
  end

  it 'verify_params works as expected' do
    params = { 'key1' => 'val1', 'key2' => 'val2' }
    allowed = [:key1, 'key2']
    expect(Lftpsun.verify_params(params, allowed)).to be(true)
    expect(Lftpsun.verify_params({}, allowed)).to be(false)
  end

  it 'command_exists? doesnt lie' do
    expect(Lftpsun.command_exists?('bash')).to be(true)
    expect(Lftpsun.command_exists?('nowaythisexists')).to be(false)
  end

  it 'download_dir is correct' do
    with_config({'client' => {'download_dir' => 'test'}}) do
      expect(Lftpsun.download_dir).to eq('test')
    end
  end

  it 'debug? is correct' do
    with_config({'debug_mode' => false}) do
      expect(Lftpsun.debug?).to eq(false)
    end
  end
end
