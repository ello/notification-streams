require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'defaulting the created_at timestamp', freeze_time: true do
    it 'sets created_at when none is provided' do
      expect(Notification.new.created_at).to eq(Time.zone.now)
    end

    it 'does not clobber a pre-set time' do
      expect(Notification.new(created_at: 1.hour.ago).created_at).to eq(1.hour.ago)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:subject_id) }
    it { is_expected.to validate_presence_of(:subject_type) }
    it { is_expected.to validate_presence_of(:kind) }

    it { is_expected.to allow_value('User').for(:subject_type) }
    it { is_expected.to allow_value('Post').for(:subject_type) }
    it { is_expected.to allow_value('Love').for(:subject_type) }
    it { is_expected.not_to allow_value('Foo').for(:subject_type) }

    Notification::NOTIFICATION_STREAM_KINDS.each do |kind|
      it { is_expected.not_to allow_value(kind).for(:kind) }
    end

    it { is_expected.not_to allow_value('foo_notification').for(:kind) }
  end
end
