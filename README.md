<img src="http://d324imu86q1bqn.cloudfront.net/uploads/user/avatar/641/large_Ello.1000x1000.png" width="200px" height="200px" />

# Notifications-Stream - Postgres-based per-user activity feeds

[![Build Status](https://travis-ci.org/ello/notifications-stream.svg?branch=master)](https://travis-ci.org/ello/notifications-stream)

Within Ello, we have two very distinct styles of streams that we display to a
user. These each have different properties, and we use different services to
back them.

One is a content stream, consisting of posts from other users that one has
elected to follow. Within Ello, these are the "Following" and "Starred"
sections. While we used to serve these streams out of Postgres, we now use our
[Streams service](https://github.com/ello/streams] in front of [Soundcloud's Roshi](https://github.com/soundcloud/roshi). This approach is much more speedy and space-efficient (it requires only a single write per post, instead of a write-per-follower), and solves a number of usabilility issues around rewriting streams on a per-user basis as they change their stream composition via following, starring and blocking. However, despite its robust safety features, Roshi is designed to be used as a cache more than the source of record for the data served out of it.

The other style of stream consists of notifications, events that
are relevant just to a single user, based on the activities of others around
them. These may be anything from mentions to invitation acceptances to new
comments on posts. In many cases, these events are the source of record for
the underlying action they represent - locating all of the potential source data
to compose a feed for a user is a time-consuming and potentially very expensive
operation, which makes it poorly suited for Roshi's approach to data storage.
They are still relatively low-cardinality, and have a strong natural key in the
form of a `{user, subject, kind, timestamp}` tuple. They also area good
candidate for periodic trimming to reduce the storage size of older data. While a number of data stores could be used for a problem of this shape, our original Postgres-based streams implementation is a great fit, for a variety of reasons. This library is an extraction of that implementation into a standalone library that can be used by any application.


### Quickstart

This is a vanilla Rails 5 (API) application, so getting it started is fairly
standard:

* Install RVM/Rbenv/Ruby 2.3
* Install PostgreSQL (9.4 or newer) if you don't have it already
* Clone this repo
* Run `bundle install` and `bundle exec rake db:setup`
* Fire up the API server with `bundle exec rails server`
* Run the test suite with `bundle exec rake`

##### Deployment, Operations, and Gotchas
To be written

## License
Streams is released under the [MIT License](blob/master/LICENSE.txt)

## Code of Conduct
Ello was created by idealists who believe that the essential nature of all human beings is to be kind, considerate, helpful, intelligent, responsible, and respectful of others. To that end, we will be enforcing [the Ello rules](https://ello.co/wtf/policies/rules/) within all of our open source projects. If you don’t follow the rules, you risk being ignored, banned, or reported for abuse.
