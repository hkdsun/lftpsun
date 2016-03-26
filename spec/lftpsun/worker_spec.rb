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

      Worker.new(@event)
    end

    it 'calls lftp.run to work' do
      LFTP.any_instance.expects(:run)
      Worker.new(@event).work
    end

    it 'sets start and finish timestamps' do
      LFTP.any_instance.stubs(:run)
      SyncEvent.any_instance.expects(:start)
      SyncEvent.any_instance.expects(:finish)
      Worker.new(@event).work
    end
  end
end
