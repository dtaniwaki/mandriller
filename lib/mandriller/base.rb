require 'action_mailer'
require_relative 'settings_methods'

class Mandriller::Base < ActionMailer::Base
  include Mandriller::SettingsMethods

  BOOLEAN_SETTINGS = {
    autotext:                  'X-MC-Autotext',
    autohtml:                  'X-MC-AutoHtml',
    url_strip_qs:              'X-MC-URLStripQS',
    preserve_recipients:       'X-MC-PreserveRecipients',
    inline_css:                'X-MC-InlineCSS',
    google_analytics_campaign: 'X-MC-GoogleAnalyticsCampaign',
    view_content_link:         'X-MC-ViewContentLink',
    import:                    'X-MC-Important',
  }
  STRING_SETTINGS = {
    tracking_domain:           'X-MC-TrackingDomain',
    signing_domain:            'X-MC-SigningDomain',
    subaccount:                'X-MC-Subaccount',
    bcc_address:               'X-MC-BccAddress',
    ip_pool:                   'X-MC-IpPool',
    return_path_domain:        'X-MC-ReturnPathDomain',
  }
  JSON_SETTINGS = {
    metadata:                  'X-MC-Metadata',
    merge_vars:                'X-MC-MergeVars',
  }
  define_settings_methods BOOLEAN_SETTINGS.keys, default: true
  define_settings_methods STRING_SETTINGS.keys
  define_settings_methods JSON_SETTINGS.keys
  define_settings_methods :open_track, default: true
  define_settings_methods :click_track, default: 'clicks'
  define_settings_methods :send_at

  class_attribute :mandrill_template, :mandrill_google_analytics

  class << self
    def set_template(template_name, block_name)
      self.mandrill_template = [template_name, block_name]
    end

    def set_google_analytics(*domains)
      self.mandrill_google_analytics = domains.flatten
    end
  end

  def set_template(template_name, block_name = nil)
    @mandrill_template = [template_name, block_name].compact
  end

  def set_google_analytics(*domains)
    @mandrill_google_analytics = domains.flatten
  end

  def mail(*args)
    m = super(*args)

    tracks = []
    tracks << ((@mandrill_open_track.nil? ? self.mandrill_open_track : @mandrill_open_track) ? 'opens' : nil)
    tracks << (@mandrill_click_track.nil? ? self.mandrill_click_track : @mandrill_click_track)
    tracks = tracks.compact.map(&:to_s)
    unless tracks.empty?
      tracks.each do |track|
        validate_values!(track, %w(opens clicks_all clicks clicks_htmlonly clicks_textonly))
      end
    end
    self.headers['X-MC-Track'] = tracks.join(',')

    v = get_mandrill_setting("template")
    unless v.nil?
      self.headers['X-MC-Template'] = v.join('|')
    end

    v = get_mandrill_setting("google_analytics")
    unless v.nil?
      self.headers['X-MC-GoogleAnalytics'] = v.join(',')
    end

    dt = @mandrill_send_at.nil? ? self.mandrill_send_at : @mandrill_send_at
    unless dt.nil?
      self.headers['X-MC-SendAt'] = dt.utc.strftime('%Y-%m-%d %H:%M:%S')
    end

    BOOLEAN_SETTINGS.each do |key, header_name|
      v = get_mandrill_setting(key)
      unless v.nil?
        self.headers[header_name] = v ? 'true' : 'false'
      end
    end

    STRING_SETTINGS.each do |key, header_name|
      v = get_mandrill_setting(key)
      unless v.nil?
        self.headers[header_name] = v.to_s
      end
    end

    JSON_SETTINGS.each do |key, header_name|
      v = get_mandrill_setting(key)
      unless v.nil?
        self.headers[header_name] = v.to_json
      end
    end

    m
  end

  private

  def validate_values!(value, valid_values)
    raise Mandriller::InvalidHeaderValue, "#{value} is not included in #{valid_values.join(', ')}" unless valid_values.include?(value)
  end
end
