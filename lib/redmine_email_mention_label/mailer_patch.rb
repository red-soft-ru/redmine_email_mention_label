# frozen_string_literal: true

module RedmineEmailMentionLabel
  module MailerPatch
    extend ActiveSupport::Concern

    prepended do
      prepend InstanceMethods
    end

    class_methods do
      def deliver_issue_add(issue)
        users = issue.notified_users | issue.notified_watchers | issue.notified_mentions
        users.each do |user|
          mention = issue.notified_mentions.include?(user)
          issue_add(user, issue, mention: mention).deliver_later
        end
      end

      def deliver_issue_edit(journal)
        users = journal.notified_users | journal.notified_watchers | journal.notified_mentions | journal.journalized.notified_mentions
        users.select! do |user|
          journal.notes? || journal.visible_details(user).any?
        end
        users.each do |user|
          mention = (journal.notified_mentions | journal.journalized.notified_mentions).include?(user)
          issue_edit(user, journal, mention: mention).deliver_later
        end
      end

      def deliver_wiki_content_added(wiki_content)
        users = wiki_content.notified_users | wiki_content.page.wiki.notified_watchers | wiki_content.notified_mentions
        users.each do |user|
          mention = wiki_content.notified_mentions.include?(user)
          wiki_content_added(user, wiki_content, mention: mention).deliver_later
        end
      end

      def deliver_wiki_content_updated(wiki_content)
        users  = wiki_content.notified_users
        users |= wiki_content.page.notified_watchers
        users |= wiki_content.page.wiki.notified_watchers
        users |= wiki_content.notified_mentions

        users.each do |user|
          mention = wiki_content.notified_mentions.include?(user)
          wiki_content_updated(user, wiki_content, mention: mention).deliver_later
        end
      end
    end

    module InstanceMethods
      def issue_add(user, issue, **options)
        email = super(user, issue)

        return email unless options[:mention]

        email.subject.prepend("[#{l(:mail_subject_mention)}]")
        email
      end

      def issue_edit(user, journal, **options)
        email = super(user, journal)

        return email unless options[:mention]

        email.subject.prepend("[#{l(:mail_subject_mention)}]")
        email
      end

      def wiki_content_added(user, wiki_content, **options)
        email = super(user, wiki_content)

        return email unless options[:mention]

        email.subject.prepend("[#{l(:mail_subject_mention)}]")
        email
      end

      def wiki_content_updated(user, wiki_content, **options)
        email = super(user, wiki_content)

        return email unless options[:mention]

        email.subject.prepend("[#{l(:mail_subject_mention)}]")
        email
      end
    end
  end
end

base = Mailer
patch = RedmineEmailMentionLabel::MailerPatch
base.prepend patch unless base.included_modules.include?(patch)
