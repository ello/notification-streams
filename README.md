<img src="http://d324imu86q1bqn.cloudfront.net/uploads/user/avatar/641/large_Ello.1000x1000.png" width="200px" height="200px" />

# Notification steams

> Postgres-based per-user activity feeds

[![Build Status](https://travis-ci.org/ello/notification-streams.svg?branch=master)](https://travis-ci.org/ello/notification-streams)
[![Code Climate](https://codeclimate.com/github/ello/notification-streams/badges/gpa.svg)](https://codeclimate.com/github/ello/notification-streams)

Within Ello, we have two very distinct styles of streams that we display to a
user. These each have different properties, and we use different services to
store and serve them.

One is a content stream, consisting of posts from other users that one has
elected to follow. Within Ello, these are the “Following” and “Starred” sections
of the app. While we used to serve these streams out of Postgres, we now use our
[Streams service](https://github.com/ello/streams) in front of
[Soundcloud's Roshi](https://github.com/soundcloud/roshi). Streams is much more
speedy and space-efficient (it requires only a single write per post, instead of
a write-per-follower), and solves a number of usabilility issues around
rewriting streams on a per-user basis as they change their stream composition
via following, starring and blocking. You can read much more about our
motivations for switching to Roshi-based streams in the Streams project README.
Despite its robust safety features, Roshi is explicitly designed to be used as a
cache and NOT the sole source for the data served out of it. Should it fail
critically for any reason, we’re able to repopulate Roshi from our primary
databases in a matter of an hour or two.

The other style of stream consists of notifications, events that are relevant
just to a single user, based on the activities of others around them. These may
be anything from mentions to invitation acceptances to new comments on posts.
Within Ello, this is the notifications pane on the web and the notifications tab
in the app. In many cases, these events are the source of record for the
underlying action they represent — locating all of the potential source data to
compose a feed for a user is a time-consuming and potentially very expensive
operation, which makes it poorly suited for mass repopulation in case of storage
failure. In addition, since a notifications stream is only displayed to a single
user, there’s no savings in storage space or performance to move that stream to
Roshi, and Postgres storage is much cheaper per-gigabyte than Redis storage
anyway.

These notifications are relatively low-cardinality, don’t require much time to
fan out on creation, and have a strong natural key in the form of a
`{user, subject, kind, timestamp}` tuple. They are a good candidate for periodic
truncation to reduce the storage size of older and infrequently-accessed data.
While a number of data stores could be used for a problem of this shape, our
original Postgres-based streams implementation is a great fit, for a variety of
reasons. This library is an extraction of that implementation into a standalone
library that can be used by any application.

### Quickstart

This is a vanilla Rails 5 (API) application, so getting it started is fairly
standard:

- Install RVM/Rbenv/Ruby 2.3
- Install PostgreSQL (9.4 or newer) if you don’t have it already
- Clone this repo
- Run `bundle install` and `bundle exec rake db:setup`
- Fire up the API server with `bundle exec rails server`
- Run the test suite with `bundle exec rake`

## License

Streams is released under the [MIT License](blob/master/LICENSE.txt)

## Code of Conduct

Ello was created by idealists who believe that the essential nature of all human
beings is to be kind, considerate, helpful, intelligent, responsible, and
respectful of others. To that end, we will be enforcing
[the Ello rules](https://ello.co/wtf/policies/rules/) within all of our open
source projects. If you don’t follow the rules, you risk being ignored, banned,
or reported for abuse.
