# Redmine Email Mention Label Plugin

## Features

This plugin adds a small label `[Mention]` to email subject when a user was mentioned:

![Preview](https://raw.githubusercontent.com/red-soft-ru/redmine_email_mention_label/144506d1cb9b20c3a35caf4d1e93a5d89ea115df/ksnip_20230428-131659.png)

Currently works only for `Issues` and `Wikis`.

## Requirements

Tested on Redmine 5.0.5 Ruby 3.1

## Installing

```bash
git clone https://github.com/red-soft-ru/redmine_email_mention_label.git plugins/redmine_email_mention_label
bundle install
```

And you're good to go!

## Uninstalling

```bash
rm -rf plugins/redmine_email_mention_label
```

## Running tests

```bash
bundle exec rails db:reset redmine:plugins:test RAILS_ENV=test NAME=redmine_email_mention_label
```
