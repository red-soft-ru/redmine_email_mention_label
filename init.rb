# frozen_string_literal: true

Redmine::Plugin.register :redmine_email_mention_label do
  name "Redmine Email Mention Label plugin"
  author "dmakurin"
  description "This plugin adds a small label [Mention] to email subject when a user was mentioned"
  version "0.0.1"
  url "https://github.com/red-soft-ru/redmine_email_mention_label"
  author_url "https://github.com/dmakurin"
end

require_relative "lib/redmine_email_mention_label"
