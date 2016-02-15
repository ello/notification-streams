class Notification < ApplicationRecord

  SELECTED_FIELDS = [ :user_id,
                      :subject_id,
                      :subject_type,
                      :created_at,
                      :kind ].freeze

  SUBJECT_TYPES = %w(User Post).freeze

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
    mentions: [ POST_MENTION_NOTIFICATION_KIND,
                COMMENT_MENTION_NOTIFICATION_KIND ],
    reposts: REPOST_NOTIFICATION_KIND,
    relationships: [ NEW_FOLLOWER_POST_KIND,
                     NEW_FOLLOWED_USER_POST_KIND ]
  }.freeze

  # We only want to validate the IDs, not the associated model - that way we don't trigger a load
  validates         :user_id,
                    :subject_id,
                    :subject_type,
                    presence: true

  validates         :subject_type,
                    presence: true,
                    inclusion: { in: SUBJECT_TYPES }

  validates         :kind,
                    presence: true,
                    inclusion: { in: NOTIFICATION_STREAM_KINDS }

  def self.for_user(user_id)
    where(user_id: user_id)
  end

  def self.for_notification_stream(user_id, category = :all)
    category ||= :all
    with_kinds_pg_93_in_fix(for_user(user_id).select(*SELECTED_FIELDS), NOTIFICATION_CATEGORIES[category.to_sym])
  end

  def self.with_kinds_pg_93_in_fix(scope, kinds)
    # When you say .where(field: array), Rails will
    # create the (correct/valid) query:
    # SELECT blah FROM table WHERE table.field IN (array_val1, array_val2)
    # But there's a bug in the PG 9.3 planner that can't
    # properly query indexes with IN clauses. To get
    # around this, we coerce the kind field into a string
    # to disambiguate the field so PG can properly use it.
    #
    # Will be fixed in 9.4. Replace this with the normal .where(field: array)
    scope.where("(kind || '') IN (?)", kinds)
  end

end
