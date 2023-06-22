# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

class MailerTest < ActiveSupport::TestCase
  fixtures :projects, :enabled_modules, :trackers, :projects_trackers, :user_preferences,
           :members, :member_roles, :roles,
           :issues, :users, :email_addresses, :issue_statuses, :enumerations,
           :journals, :journal_details,
           :wikis, :wiki_pages, :wiki_contents

  include Redmine::I18n

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:users_002) # jsmith
  end

  def test_issue_add_has_a_mention_label
    issue = Issue.generate!(project_id: 1, description: "Hello, @jsmith")
    email = Mailer.issue_add(@user, issue, mention: true)

    assert_include l(:mail_subject_mention), email.subject
  end

  def test_issue_edit_has_a_mention_label
    journal = Journal.generate!(journalized_id: 1, journalized_type: "Issue", notes: "I am a note, what about you @jsmith")
    email = Mailer.issue_edit(@user, journal, mention: true)

    assert_include l(:mail_subject_mention), email.subject
  end

  def test_wiki_content_added_has_a_mention_label
    wiki_content = WikiContent.create!(page_id: 1, version: 1, text: "Hello, @jsmith")
    email = Mailer.wiki_content_added(@user, wiki_content, mention: true)

    assert_include l(:mail_subject_mention), email.subject
  end

  def test_wiki_content_updated_has_a_mention_label
    wiki_content = WikiContent.find(1)
    wiki_content.update(text: "@jsmith")
    email = Mailer.wiki_content_updated(@user, wiki_content, mention: true)

    assert_include l(:mail_subject_mention), email.subject
  end

  def test_issue_add_sends_a_notification_via_mention
    issue = Issue.generate!(project_id: 1, description: "Hello, @jsmith")
    Mailer.deliver_issue_add(issue)
    email = emails_by_recipients(@user.mail).first

    assert_not_nil email
    assert_include l(:mail_subject_mention), email.subject
  end

  def test_issue_edit_sends_a_notification_via_mention
    journal = Journal.generate!(journalized_id: 1, journalized_type: "Issue", notes: "I am a note, what about you @jsmith")
    Mailer.deliver_issue_edit(journal)
    email = emails_by_recipients(@user.mail).first

    assert_not_nil email
    assert_include l(:mail_subject_mention), email.subject
  end

  def test_wiki_content_added_sends_a_notification
    wiki_content = WikiContent.create!(page_id: 1, version: 1, text: "Hello, @jsmith.")
    Mailer.deliver_wiki_content_added(wiki_content)
    email = emails_by_recipients(@user.mail).first

    assert_not_nil email
    assert_include l(:mail_subject_mention), email.subject
  end

  def test_wiki_content_updated_sends_a_notification
    wiki_content = WikiContent.find(1)
    wiki_content.update(text: "@jsmith")
    Mailer.deliver_wiki_content_updated(wiki_content)
    email = emails_by_recipients(@user.mail).first

    assert_not_nil email
    assert_include l(:mail_subject_mention), email.subject
  end

  private

  # Returns an array of +mail+ objects that were sent to +recipients+
  # Usage: email_by_recipients("jsmith@somenet.foo", "dlopper@somenet.foo")
  def emails_by_recipients(*recipients)
    ActionMailer::Base.deliveries.select { |m| (recipients & m.to).present? }
  end
end
