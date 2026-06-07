FirstTask
===========================

A new task manager for our friends.

Author
---------------------------

* [suer](https://github.com/suer/)
* [mallowlabs](https://github.com/mallowlabs/)

Build
---------------------------

### Required

* Xcode
* Bundler

### Deploy

You need a [Firebase](https://firebase.google.com/) account.

```sh
$ bundle install
$ TEAM_ID=xxx \
  APP_DISTRIBUTION_GROUP=xxx \
  APP_DISTRIBUTION_MESSAGE=xxx \
  bundle exec fastlane beta
```
