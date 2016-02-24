require 'rails_helper'

RSpec.describe TrimQueue, type: :model do

  before do
    TrimQueue.clear
  end

  describe 'pushing and popping items ' do
    it 'returns an item pushed onto the queue when popping' do
      TrimQueue.push(1)
      expect(TrimQueue.pop).to eq(1)
    end

    it 'returns nil when no items remain to be popped' do
      expect(TrimQueue.pop).to be_nil
    end
  end
end
