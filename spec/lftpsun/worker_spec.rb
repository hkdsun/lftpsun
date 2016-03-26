require 'spec_helper'

module Lftpsun
  describe Worker do

    before(:each) do
      @event = SyncEvent.new({
        'path' => 'src_path',
        'label' => 'sample_label',
        'host' => 'localhost_test'
      })
    end

    it 'initializes LFTP with correct params' do
      LFTP.expects(:new).with(
        source: @event.src_path,
        destination: @event.dest_path,
        host: @event.host
      )

      Woker.new(@event).work
    end

    it 'marks the start and end of event' do

    end
  end
end
