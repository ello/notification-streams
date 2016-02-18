class Notification < ApplicationRecord

  SELECTED_FIELDS = [ :user_id,
                      :subject_id,
                      :subject_type,
                      :created_at,
                      :kind ].freeze

  SUBJECT_TYPES = %w(User Post Love).freeze

  INVITATION_ACCEPTED_POST_KIND = 'invitation_accepted_post'.freeze
  NEW_FOLLOWED_USER_POST_KIND = 'new_followed_user_post'.freeze
  NEW_FOLLOWER_POST_KIND = 'new_follower_post'.freeze
  POST_MENTION_NOTIFICATION_KIND = 'post_mention_notification'.freeze
  COMMENT_MENTION_NOTIFICATION_KIND = 'comment_mention_notification'.freeze
  COMMENT_NOTIFICATION_KIND = 'comment_notification'.freeze
  COMMENT_ON_REPOST_NOTIFICATION_KIND = 'comment_on_repost_notification'.freeze
  COMMENT_ON_ORIGINAL_POST_NOTIFICATION_KIND = 'comment_on_original_post_notification'.freeze
  LOVE_NOTIFICATION_KIND = 'love_notification'.freeze
  LOVE_ON_REPOST_NOTIFICATION_KIND = 'love_on_repost_notification'.freeze
  LOVE_ON_ORIGINAL_POST_NOTIFICATION_KIND = 'love_on_original_post_notification'.freeze
  WELCOME_NOTIFICATION_KIND = 'welcome_notification'.freeze
  REPOST_NOTIFICATION_KIND = 'repost_notification'.freeze

  NOTIFICATION_STREAM_KINDS = [
    NEW_FOLLOWER_POST_KIND,
    NEW_FOLLOWED_USER_POST_KIND,
    INVITATION_ACCEPTED_POST_KIND,
    POST_MENTION_NOTIFICATION_KIND,
    COMMENT_MENTION_NOTIFICATION_KIND,
    COMMENT_NOTIFICATION_KIND,
    COMMENT_ON_REPOST_NOTIFICATION_KIND,
    COMMENT_ON_ORIGINAL_POST_NOTIFICATION_KIND,
    LOVE_NOTIFICATION_KIND,
    LOVE_ON_REPOST_NOTIFICATION_KIND,
    LOVE_ON_ORIGINAL_POST_NOTIFICATION_KIND,
    WELCOME_NOTIFICATION_KIND,
    REPOST_NOTIFICATION_KIND
  ].freeze

  NOTIFICATION_CATEGORIES = {
    all: NOTIFICATION_STREAM_KINDS,
    comments: [
      COMMENT_NOTIFICATION_KIND,
      COMMENT_ON_REPOST_NOTIFICATION_KIND,
      COMMENT_ON_ORIGINAL_POST_NOTIFICATION_KIND
    ],
    loves: [
      LOVE_NOTIFICATION_KIND,
      LOVE_ON_REPOST_NOTIFICATION_KIND,
      LOVE_ON_ORIGINAL_POST_NOTIFICATION_KIND
    ],
    mentions: [
      POST_MENTION_NOTIFICATION_KIND,
      COMMENT_MENTION_NOTIFICATION_KIND
    ],
    reposts: REPOST_NOTIFICATION_KIND,
    relationships: [
      NEW_FOLLOWER_POST_KIND,
      NEW_FOLLOWED_USER_POST_KIND
    ]
  }.freeze

  validates         :user_id,
                    :subject_id,
                    presence: true

  validates         :subject_type,
                    presence: true,
                    inclusion: { in: SUBJECT_TYPES }

  validates         :kind,
                    presence: true,
                    inclusion: { in: NOTIFICATION_STREAM_KINDS }

  after_initialize do
    self.created_at ||= Time.zone.now
  end

  def self.for_user(user_id)
    where(user_id: user_id)
  end

  def self.for_notification_stream(user_id,
                                   category = nil,
                                   excluded_originating_user_ids = [],
                                   before = nil,
                                   limit = nil)
    category ||= :all
    limit ||= 25
    before = Time.parse(before) if before.is_a?(String)
    before ||= Time.zone.now

    for_user(user_id).
      select(*SELECTED_FIELDS).
      where(kind: NOTIFICATION_CATEGORIES[category.to_sym]).
      where.not(originating_user_id: excluded_originating_user_ids).
      where('created_at < ?', before).
      order('created_at DESC').
      limit(limit)
  end

  def as_json(options = nil)
    attributes.slice(*%w(user_id subject_id subject_type kind created_at))
  end

end
