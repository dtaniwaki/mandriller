# mandriller

[![Gem Version](https://badge.fury.io/rb/mandriller.svg)](http://badge.fury.io/rb/mandriller) [![Build Status](https://secure.travis-ci.org/dtaniwaki/mandriller.png)](http://travis-ci.org/dtaniwaki/mandriller) [![Coverage Status](https://coveralls.io/repos/dtaniwaki/mandriller/badge.png)](https://coveralls.io/r/dtaniwaki/mandriller) [![Code Climate](https://codeclimate.com/github/dtaniwaki/mandriller.png)](https://codeclimate.com/github/dtaniwaki/mandriller)

[Mandrill](http://mandrill.com/) SMTP API integration for ActionMailer.
See detail of the protocol on [the official page](http://help.mandrill.com/entries/21688056-Using-SMTP-Headers-to-customize-your-messages).

## Installation

Add the mandriller gem to your Gemfile.

```ruby
gem "mandriller"
```

And run `bundle install`.

## Usage

```ruby
class UserMailer < Mandriller::Base
  set_google_analytics_campaign
  set_open_track

  def test_mail
    set_click_track
    mail from: 'from@example.com', to: 'to@example.com'
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2014 Daisuke Taniwaki. See [LICENSE](LICENSE) for details.
