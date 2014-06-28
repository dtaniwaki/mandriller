# mandriller

Mandriller SMTP API integration for ActionMailer.

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
