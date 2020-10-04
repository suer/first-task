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

You need a [DeployGate](https://deploygate.com/) account.

```sh
$ bundle install
$ TEAM_ID=xxx \
  DEPLOYGATE_API_KEY=xxx \
  DEPLOYGATE_USER=xxx \
  bundle exec fastlane dg
```
