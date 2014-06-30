require 'action_mailer'
require 'multi_json'
require_relative 'settings_methods'

class Mandriller::Base < ActionMailer::Base
  include Mandriller::SettingsMethods

  BOOLEAN_SETTINGS = {
    autotext:                  'X-MC-Autotext',
    autohtml:                  'X-MC-AutoHtml',
    url_strip_qs:              'X-MC-URLStripQS',
    preserve_recipients:       'X-MC-PreserveRecipients',
    inline_css:                'X-MC-InlineCSS',
    view_content_link:         'X-MC-ViewContentLink',
    import:                    'X-MC-Important',
  }
  STRING_SETTINGS = {
    tracking_domain:           'X-MC-TrackingDomain',
    signing_domain:            'X-MC-SigningDomain',
    subaccount:                'X-MC-Subaccount',
    bcc_address:               'X-MC-BccAddress',
    ip_pool:                   'X-MC-IpPool',
    google_analytics_campaign: 'X-MC-GoogleAnalyticsCampaign',
    return_path_domain:        'X-MC-ReturnPathDomain',
  }
  JSON_SETTINGS = {
    metadata:                  'X-MC-Metadata',
    merge_vars:                'X-MC-MergeVars',
  }
  ARRAY_SETTINGS = {
    google_analytics:          'X-MC-GoogleAnalytics',
    tags:                      'X-MC-Tags',
  }
  define_settings_methods BOOLEAN_SETTINGS.keys, default: true, getter: lambda { |v| v ? 'true' : 'false' }
  define_settings_methods STRING_SETTINGS.keys, getter: lambda { |v| v.to_s }
  define_settings_methods JSON_SETTINGS.keys, getter: lambda { |v| MultiJson.dump(v) }
  define_settings_methods ARRAY_SETTINGS.keys, getter: lambda { |v| Array(v).join(',') }
  define_settings_methods :open_track, default: true
  define_settings_methods :click_track, default: 'all'
  define_settings_methods :send_at

  class_attribute :mandrill_template

  class << self
    def set_template(template_name, block_name = nil)
      self.mandrill_template = [template_name, block_name]
    end
  end

  def set_template(template_name, block_name = nil)
    @mandrill_template = [template_name, block_name].compact
  end

  def mail(*args)
    tracks = []
    tracks << (get_mandrill_setting_value("open_track") ? 'opens' : nil)
    if v = get_mandrill_setting_value("click_track")
      tracks << "clicks_#{v}"
    end
    tracks = tracks.compact.map(&:to_s)
    unless tracks.empty?
      tracks.each do |track|
        validate_values!(track, %w(opens clicks_all clicks_htmlonly clicks_textonly))
      end
      self.headers['X-MC-Track'] = tracks.join(',')
    end

    v = get_mandrill_setting_value("template")
    self.headers['X-MC-Template'] = v.join('|') unless v.nil? || v.empty?

    v = get_mandrill_setting_value("send_at")
    self.headers['X-MC-SendAt'] = v.to_time.utc.strftime('%Y-%m-%d %H:%M:%S') unless v.nil?

    (BOOLEAN_SETTINGS.to_a + STRING_SETTINGS.to_a + JSON_SETTINGS.to_a + ARRAY_SETTINGS.to_a).each do |key, header_name|
      if is_mandrill_setting_defined?(key)
        self.headers[header_name] = get_mandrill_setting(key)
      end
    end

    super(*args)
  end

  private

  def validate_values!(value, valid_values)
    raise Mandriller::InvalidHeaderValue, "#{value} is not included in #{valid_values.join(', ')}" unless valid_values.include?(value)
  end
end
