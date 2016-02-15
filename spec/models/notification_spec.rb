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
    let(:notification) { Notification.new }

    it 'is invalid if user_id is blank' do
      expect(notification.valid?).to be_falsy
      expect(notification.errors['user_id']).to include("can't be blank")
    end

    it 'is invalid if subject_id is blank' do
      expect(notification.valid?).to be_falsy
      expect(notification.errors['subject_id']).to include("can't be blank")
    end

    it 'is invalid if subject_type is blank' do
      expect(notification.valid?).to be_falsy
      expect(notification.errors['subject_type']).to include("can't be blank")
    end

    it 'is invalid if subject_type is not a valid type' do
      notification.subject_type = 'Foo'
      expect(notification.valid?).to be_falsy
      expect(notification.errors['subject_type'])
        .to include('is not included in the list')
    end

    it 'is invalid if kind is blank' do
      expect(notification.valid?).to be_falsy
      expect(notification.errors['kind']).to include("can't be blank")
    end

    it 'is invalid if kind is not a valid kind' do
      notification.kind = 'foo_notification'
      expect(notification.valid?).to be_falsy
      expect(notification.errors['kind'])
        .to include('is not included in the list')
    end
  end
end
