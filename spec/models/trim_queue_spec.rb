# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrimQueue, type: :model do

  before do
    described_class.clear
  end

  describe 'pushing and popping items ' do
    it 'returns an item pushed onto the queue when popping' do
      described_class.push(1)
      expect(described_class.pop).to eq(1)
    end

    it 'returns nil when no items remain to be popped' do
      expect(described_class.pop).to be_nil
    end
  end
end
