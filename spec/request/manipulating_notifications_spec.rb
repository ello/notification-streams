# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength, RSpec/LetSetup, RSpec/OverwritingSetup
RSpec.describe 'Manipulating notifications via the API', type: :request, freeze_time: true do
  before do
    allow(TrimQueue).to receive(:push)
  end

  let(:response_json) { JSON.parse(response.body) }

  describe 'creating a notification for a user' do
    describe 'when valid parameters are passed' do
      before do
        post '/api/v1/users/1/notifications', params: { subject_id: 10,
                                                        subject_type: 'Post',
                                                        kind: Notification::COMMENT_MENTION_NOTIFICATION_KIND,
                                                        originating_user_id: 1,
                                                        created_at: 1.day.ago }
      end

      let(:notification) { Notification.first }

      it 'creates a new Notification object' do
        expect(Notification.count).to eq(1)
        expect(notification.subject_id).to eq(10)
        expect(notification.subject_type).to eq('Post')
        expect(notification.kind).to eq(Notification::COMMENT_MENTION_NOTIFICATION_KIND)
        expect(notification.originating_user_id).to eq(1)
        expect(notification.created_at).to eq(1.day.ago)
      end

      it 'responds with a 201 and an empty body' do
        expect(response.status).to eq(201)
        expect(response.body).to be_empty
      end

      it 'pushes the user ID onto the trim queue' do
        expect(TrimQueue).to have_received(:push).with('1')
      end

      describe 'when attempting to insert duplicates' do
        before do
          post '/api/v1/users/1/notifications', params: { subject_id: 10,
                                                          subject_type: 'Post',
                                                          kind: Notification::COMMENT_MENTION_NOTIFICATION_KIND,
                                                          originating_user_id: 1,
                                                          created_at: 1.day.ago }
        end

        it 'does not create duplicate objects' do
          expect(Notification.count).to eq(1)
        end

        it 'still responds with a 201 and an empty body' do
          expect(response.status).to eq(201)
          expect(response.body).to be_empty
        end

        it 'only pushes the user ID onto the trim queue once' do
          expect(TrimQueue).to have_received(:push).once
        end
      end
    end

    describe 'when invalid parameters are passed' do
      before do
        post '/api/v1/users/1/notifications', params: {}
      end

      it 'does not create any Notification objects' do
        expect(Notification.count).to eq(0)
      end

      it 'responds with a 422 and an empty body' do
        expect(response.status).to eq(422)
        expect(response_json).to eq(
          'errors' => {
            'subject_id' => ["can't be blank"],
            'subject_type' => ["can't be blank", 'is not included in the list'],
            'kind' => ["can't be blank", 'is not included in the list']
          }
        )
      end

      it 'does not push the user ID onto the trim queue' do
        expect(TrimQueue).not_to have_received(:push)
      end
    end
  end

  describe 'retrieving notifications for a user', freeze_time: true do
    let!(:notification1) do
      CreateNotificationForUser.call(user_id: 1,
                                     kind: Notification::COMMENT_NOTIFICATION_KIND,
                                     subject_id: 10,
                                     subject_type: 'Post',
                                     originating_user_id: 2,
                                     created_at: 2.days.ago)
    end
    let!(:notification2) do
      CreateNotificationForUser.call(user_id: 1,
                                     kind: Notification::LOVE_NOTIFICATION_KIND,
                                     subject_id: 11,
                                     subject_type: 'Post',
                                     originating_user_id: 3,
                                     created_at: 1.day.ago)
    end

    describe 'without any parameters' do
      before do
        get '/api/v1/users/1/notifications'
      end

      it 'returns notifications in reverse chronological order' do
        expect(response.status).to eq(200)
        expect(response_json).to eq(
          [
            { 'user_id' => 1,
              'subject_id' => 11,
              'subject_type' => 'Post',
              'kind' => 'love_notification',
              'created_at' => 1.day.ago.strftime(Notification::TIME_STAMP_FORMAT),
              'originating_user_id' => 3 },
            { 'user_id' => 1,
              'subject_id' => 10,
              'subject_type' => 'Post',
              'kind' => 'comment_notification',
              'created_at' => 2.days.ago.strftime(Notification::TIME_STAMP_FORMAT),
              'originating_user_id' => 2 }
          ]
        )
      end
    end

    describe 'filtering by category' do
      before do
        get '/api/v1/users/1/notifications', params: { category: 'loves' }
      end

      it 'only returns notifications in the specified category' do
        expect(response.status).to eq(200)
        expect(response_json).to eq(
          [
            { 'user_id' => 1,
              'subject_id' => 11,
              'subject_type' => 'Post',
              'kind' => 'love_notification',
              'created_at' => 1.day.ago.strftime(Notification::TIME_STAMP_FORMAT),
              'originating_user_id' => 3 }
          ]
        )
      end
    end

    describe 'filtering by excluding originating user ids' do
      before do
        get '/api/v1/users/1/notifications', params: { exclude_originating_user_ids: '2,5' }
      end

      it 'does not return notifications from the specified originating user' do
        expect(response.status).to eq(200)
        expect(response_json).to eq(
          [
            { 'user_id' => 1,
              'subject_id' => 11,
              'subject_type' => 'Post',
              'kind' => 'love_notification',
              'created_at' => 1.day.ago.strftime(Notification::TIME_STAMP_FORMAT),
              'originating_user_id' => 3 }
          ]
        )
      end
    end

    describe 'paginating by timestamp' do
      before do
        get '/api/v1/users/1/notifications', params: { before: 1.day.ago.as_json }
      end

      it 'only returns notifications before the specified timestamp' do
        expect(response.status).to eq(200)
        expect(response_json).to eq(
          [
            { 'user_id' => 1,
              'subject_id' => 10,
              'subject_type' => 'Post',
              'kind' => 'comment_notification',
              'created_at' => 2.days.ago.strftime(Notification::TIME_STAMP_FORMAT),
              'originating_user_id' => 2 }
          ]
        )
      end
    end

    describe 'limiting results' do
      before do
        get '/api/v1/users/1/notifications', params: { limit: 1 }
      end

      it 'only returns the specified number of results' do
        expect(response.status).to eq(200)
        expect(response_json).to eq(
          [
            { 'user_id' => 1,
              'subject_id' => 11,
              'subject_type' => 'Post',
              'kind' => 'love_notification',
              'created_at' => 1.day.ago.strftime(Notification::TIME_STAMP_FORMAT),
              'originating_user_id' => 3 }
          ]
        )
      end
    end

  end

  describe 'deleting notifications for a user' do
    let!(:notification) do
      CreateNotificationForUser.call(user_id: 1,
                                     kind: Notification::COMMENT_MENTION_NOTIFICATION_KIND,
                                     subject_id: 10,
                                     subject_type: 'Post',
                                     originating_user_id: 2,
                                     created_at: Time.zone.now)
    end
    let!(:notification) do
      CreateNotificationForUser.call(user_id: 2,
                                     kind: Notification::COMMENT_MENTION_NOTIFICATION_KIND,
                                     subject_id: 10,
                                     subject_type: 'Post',
                                     originating_user_id: 1,
                                     created_at: Time.zone.now)
    end

    before do
      delete '/api/v1/users/1/notifications'
    end

    it 'removes all notifications for that user' do
      expect(Notification.where(user_id: 1).count).to eq(0)
    end

    it 'removes all notifications originating from that user' do
      expect(Notification.where(originating_user_id: 1).count).to eq(0)
    end

    it 'responds with a 202 and an empty body' do
      expect(response.status).to eq(202)
      expect(response.body).to be_empty
    end
  end

  describe 'deleting notifications for a subject' do
    let(:notification) do
      CreateNotificationForUser.call(user_id: 1,
                                     kind: Notification::COMMENT_MENTION_NOTIFICATION_KIND,
                                     subject_id: 10,
                                     subject_type: 'Post',
                                     originating_user_id: 2,
                                     created_at: Time.zone.now)
    end

    before do
      delete '/api/v1/notifications', params: { subject_id: 10, subject_type: 'Post' }
    end

    it 'removes all notifications for that subject id/type' do
      expect(Notification.where(subject_id: 10, subject_type: 'Post').count).to eq(0)
    end

    it 'responds with a 202 and an empty body' do
      expect(response.status).to eq(202)
      expect(response.body).to be_empty
    end
  end
end
# rubocop:enable Metrics/BlockLength, RSpec/LetSetup, RSpec/OverwritingSetup
