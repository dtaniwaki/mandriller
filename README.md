# mandriller

[![Gem Version][gem-image]][gem-link]
[![Dependency Status][deps-image]][deps-link]
[![Build Status][build-image]][build-link]
[![Coverage Status][cov-image]][cov-link]
[![Code Climate][gpa-image]][gpa-link]

[Mandrill](http://mandrill.com/) SMTP API integration for ActionMailer.
See detail of the protocol on [the official page](http://help.mandrill.com/entries/21688056-Using-SMTP-Headers-to-customize-your-messages).

## Installation

Add the mandriller gem to your Gemfile.

```ruby
gem "mandriller"
```

And run `bundle install`.

Add the following into any environment's settings in `config/environments/`.

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  :user_name => 'UserName',
  :password => 'Password',
  :address => "smtp.mandrillapp.com",
  :domain => "your-domain.com",
  :enable_starttls_auto => true,
  :authentication => 'login',
  :port => 587,
}
```

## Usage

e.g.

```ruby
class UserMailer < Mandriller::Base
  include AbstractController::Callbacks # To use before_filter in ActionMailer::Base

  set_open_track
  set_click_track
  set_google_analytics [Settings.root_host, Settings.admin.host].uniq

  before_filter do
    set_google_analytics_campaign "#{mailer_name.gsub(/_mailer$/, '')}/#{action_name.gsub(/_email$/, '')}"
  end

  def test_mail
    mail from: 'from@example.com', to: 'to@example.com'
  end
end
```

You can set the options globally and locally. Locally set option overwrites the one globally set. Just add any settings necessary for your mailers from the list below.

## Settings

### set_open_track

Enable open-tracking for the message.

- `set_open_track` or `set_open_track true`: Enable
- `set_open_track false`: Disable

### set_click_track

Enable click-tracking for the message.

- `set_click_track 'all'`: enables click tracking on all emails
- `set_click_track 'htmlonly'`: enables click tracking only on html emails
- `set_click_track 'textonly'`: enables click tracking only on text emails

### set_auto_text

Automatically generate a plain-text version of the email from the HTML content.

- `set_auto_text` or `set_auto_text true`: Enable
- `set_auto_text false`: Disable

### set_auto_html

Automatically generate an HTML version of the email from the plain-text content.

- `set_auto_html` or `set_auto_html true`: Enable
- `set_auto_html false`: Disable

### set_template

Use an HTML template stored in your Mandrill account

- `set_template 'template_name'` or `set_template 'template_name', 'block_name'`: 

`template_name`

the name of the stored template.

`block_name`

the name of the mc:edit region where the body of the SMTP generated message will be placed. Optional and defaults to "main".

### set_merge_vars

Add dynamic data to replace mergetags that appear in your message content.

- `set_merge_vars foo: 1, bar: 2`

### set_google_analytics

Add Google Analytics tracking to links in your email for the specified domains.

- `set_google_analytics ['foo.com', 'bar.com'`]

### set_google_analytics_campaign

Add an optional value to be used for the __utm_campaign parameter__ in Google Analytics tracked links.

- `set_google_analytics 'campaign_name'`

### set_metadata

Information about any custom fields or data you want to append to the message.

- `set_metadata foo: 1, bar: 2`

### set_url_strip_qs

Whether to strip querystrings from links for reporting.

- `set_url_strip_qs` or `set_url_strip_qs true`: Enable
- `set_url_strip_qs false`: Disable

### set_preserve_recipients

Whether to show recipients of the email other recipients, such as those in the "cc" field.

- `set_preserve_recipients` or `set_preserve_recipients true`: Enable
- `set_preserve_recipients false`: Disable

### set_inline_css

Whether to inline the CSS for the HTML version of the email (only for HTML documents less than 256KB).

- `set_inline_css` or `set_inline_css true`: Enable
- `set_inline_css false`: Disable

### set_tracking_domain

Set a [custom domain to use for tracking opens and clicks](http://help.mandrill.com/entries/23353682-Can-I-customize-the-domain-used-for-open-and-click-tracking-) instead of mandrillapp.com.

- `set_tracking_domain` or `set_tracking_domain true`: Enable
- `set_tracking_domain false`: Disable

### set_signing_domain

Set a [custom domain to use for SPF/DKIM signing](http://help.mandrill.com/entries/23374656-Can-I-send-emails-on-behalf-of-my-clients-) instead of mandrill (for "via" or "on behalf of" in email clients).

- `set_signing_domain` or `set_signing_domain true`: Enable
- `set_signing_domain false`: Disable

### set_subaccount

Select a [subaccount](http://help.mandrill.com/entries/25523278-What-are-subaccounts-) for sending the mail.

- `set_subaccount 'subaccount_id'`

### set_view_content_link

Control whether the View Content link appears for emails sent for your account.

- `set_view_content_link` or `set_view_content_link true`: Enable
- `set_view_content_link false`: Disable

### set_bcc_address

An optional address that will receive an exact copy of the message, including all tracking data

- `set_bcc_address 'email_address'`

### set_important

Whether this message is [important](http://help.mandrill.com/entries/23664027-Does-Mandrill-allow-me-to-prioritize-messages-) and should be delivered ahead of non-important messages

- `set_important` or `set_important true`: Enable
- `set_important false`: Disable

### set_ip_pool

Specify a [dedicated IP pool](http://help.mandrill.com/entries/24182062-Can-I-choose-which-dedicated-IP-pool-my-Mandrill-emails-send-from-) for the message.

- `set_ip_pool 'dedicated_ip_pool'`

### set_return_path_domain

Specify a [custom domain](http://help.mandrill.com/entries/25241243-Can-I-customize-the-Return-Path-bounce-address-used-for-my-emails-) to use for the message's return-path

- `set_return_path_domain 'example.com'`

### set_send_at

Specify a future date/time that the message should be [scheduled](http://help.mandrill.com/entries/24331201-Can-I-schedule-a-message-to-send-at-a-specific-time-) for delivery

- `set_send_at 5.days.from_now`

__Only available for paid accounts__

### set_tags

Add tags to your emails.

- `set_tags ['tag1', 'tag2'`]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2014 Daisuke Taniwaki. See [LICENSE](LICENSE) for details.



[gem-image]:   https://badge.fury.io/rb/mandriller.svg
[gem-link]:    http://badge.fury.io/rb/mandriller
[build-image]: https://secure.travis-ci.org/dtaniwaki/mandriller.png?branch=master
[build-link]:  http://travis-ci.org/dtaniwaki/mandriller?branch=master
[deps-image]:  https://gemnasium.com/dtaniwaki/mandriller.svg?branch=master
[deps-link]:   https://gemnasium.com/dtaniwaki/mandriller?branch=master
[cov-image]:   https://coveralls.io/repos/dtaniwaki/mandriller/badge.png?branch=master
[cov-link]:    https://coveralls.io/r/dtaniwaki/mandriller?branch=master
[gpa-image]:   https://codeclimate.com/github/dtaniwaki/mandriller.png?branch=master
[gpa-link]:    https://codeclimate.com/github/dtaniwaki/mandriller?branch=master

