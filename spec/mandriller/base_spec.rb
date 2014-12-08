require 'spec_helper'

describe Mandriller::Base do
  let(:global_settings) { lambda{} }
  let(:local_settings) { lambda{} }
  let(:klass) do
    gs = global_settings
    ls = local_settings
    klass = Class.new(Mandriller::Base) do
      self.mailer_name = 'foo_mailer'
      instance_exec(&gs)
      define_method :foo do
        instance_exec(&ls)
        mail from: 'from@example.com', to: ['to@example.com']
      end
    end
    allow_any_instance_of(ActionMailer::Base).to receive(:each_template).and_return('')
    klass
  end
  subject { klass.foo }

  BOOLEAN_SETTINGS = {
    autotext:                  'X-MC-Autotext',
    autohtml:                  'X-MC-AutoHtml',
    url_strip_qs:              'X-MC-URLStripQS',
    preserve_recipients:       'X-MC-PreserveRecipients',
    inline_css:                'X-MC-InlineCSS',
    view_content_link:         'X-MC-ViewContentLink',
    important:                 'X-MC-Important',
  }
  BOOLEAN_SETTINGS.each do |key, header|
    describe "#{header} header" do
      context "no set" do
        it_behaves_like "without header", header
      end
      context "set by #set_#{key}" do
        context "set default" do
          let(:local_settings) { lambda{ __send__("set_#{key}") } }
          it_behaves_like "with header", header, true
        end
        context "set true" do
          let(:local_settings) { lambda{ __send__("set_#{key}", true) } }
          it_behaves_like "with header", header, true
        end
        context "set false" do
          let(:local_settings) { lambda{ __send__("set_#{key}", false) } }
          it_behaves_like "with header", header, false
        end
      end
      context "set by ::set_#{key}" do
        context "set default" do
          let(:global_settings) { lambda{ __send__("set_#{key}") } }
          it_behaves_like "with header", header, true
        end
        context "set true" do
          let(:global_settings) { lambda{ __send__("set_#{key}", true) } }
          it_behaves_like "with header", header, true
        end
        context "set false" do
          let(:global_settings) { lambda{ __send__("set_#{key}", false) } }
        end
      end
      context "set by both #set_#{key} and ::set_#{key}" do
        context "set true globally and set false locally" do
          let(:global_settings) { lambda{ __send__("set_#{key}", true) } }
          let(:local_settings) { lambda{ __send__("set_#{key}", false) } }
          it_behaves_like "with header", header, false
        end
        context "set false globally and set true locally" do
          let(:global_settings) { lambda{ __send__("set_#{key}", false) } }
          let(:local_settings) { lambda{ __send__("set_#{key}", true) } }
          it_behaves_like "with header", header, true
        end
        context "set value globally but set nil locally" do
          let(:global_settings) { lambda{ __send__("set_#{key}", true) } }
          let(:local_settings) { lambda{ __send__("set_#{key}", nil) } }
          it_behaves_like "without header", header
        end
      end
    end
  end

  STRING_SETTINGS = {
    tracking_domain:           'X-MC-TrackingDomain',
    signing_domain:            'X-MC-SigningDomain',
    subaccount:                'X-MC-Subaccount',
    bcc_address:               'X-MC-BccAddress',
    ip_pool:                   'X-MC-IpPool',
    google_analytics_campaign: 'X-MC-GoogleAnalyticsCampaign',
    return_path_domain:        'X-MC-ReturnPathDomain',
  }
  STRING_SETTINGS.each do |key, header|
    describe "#{header} header" do
      context "no set" do
        it_behaves_like "without header", header
      end
      context "set by #set_#{key}" do
        let(:local_settings) { lambda{ __send__("set_#{key}", 'local-string') } }
        it_behaves_like "with header", header, 'local-string'
      end
      context "set by ::set_#{key}" do
        let(:global_settings) { lambda{ __send__("set_#{key}", 'global-string') } }
        it_behaves_like "with header", header, 'global-string'
      end
      context "set by both #set_#{key} and ::set_#{key}" do
        context "set value globally and set value locally" do
          let(:global_settings) { lambda{ __send__("set_#{key}", 'global-string') } }
          let(:local_settings) { lambda{ __send__("set_#{key}", 'local-string') } }
          it_behaves_like "with header", header, 'local-string'
        end
        context "set value globally but set nil locally" do
          let(:global_settings) { lambda{ __send__("set_#{key}", 'global-string') } }
          let(:local_settings) { lambda{ __send__("set_#{key}", nil) } }
          it_behaves_like "without header", header
        end
      end
    end
  end

  JSON_SETTINGS = {
    metadata:                  'X-MC-Metadata',
    merge_vars:                'X-MC-MergeVars',
  }
  JSON_SETTINGS.each do |key, header|
    describe "#{header} header" do
      context "no set" do
        it_behaves_like "without header", header
      end
      context "set by #set_#{key}" do
        let(:local_settings) { lambda{ __send__("set_#{key}", {local: 1}) } }
        it_behaves_like "with header", header, '{"local":1}'
      end
      context "set by ::set_#{key}" do
        let(:global_settings) { lambda{ __send__("set_#{key}", {global: 1}) } }
        it_behaves_like "with header", header, '{"global":1}'
      end
      context "set by both #set_#{key} and ::set_#{key}" do
        context "set value globally and set value locally" do
          let(:global_settings) { lambda{ __send__("set_#{key}", {global: 1}) } }
          let(:local_settings) { lambda{ __send__("set_#{key}", {local: 1}) } }
          it_behaves_like "with header", header, '{"local":1}'
        end
        context "set value globally but set nil locally" do
          let(:global_settings) { lambda{ __send__("set_#{key}", {global: 1}) } }
          let(:local_settings) { lambda{ __send__("set_#{key}", nil) } }
          it_behaves_like "without header", header
        end
      end
    end
  end

  ARRAY_SETTINGS = {
    google_analytics:     'X-MC-GoogleAnalytics',
    tags:                 'X-MC-Tags',
  }
  ARRAY_SETTINGS.each do |key, header|
    describe "#{header} header" do
      context "no set" do
        it_behaves_like "without header", header
      end
      context "set by #set_#{key}" do
        let(:local_settings) { lambda{ __send__("set_#{key}", ['string1', 'string2']) } }
        it_behaves_like "with header", header, 'string1,string2'
      end
      context "set by ::set_#{key}" do
        let(:global_settings) { lambda{ __send__("set_#{key}", ['string1', 'string2']) } }
        it_behaves_like "with header", header, 'string1,string2'
      end
      context "set by both #set_#{key} and ::set_#{key}" do
        context "set value globally and set value locally" do
          let(:global_settings) { lambda{ __send__("set_#{key}", ['string1', 'string2']) } }
          let(:local_settings) { lambda{ __send__("set_#{key}", ['string2', 'string3']) } }
          it_behaves_like "with header", header, 'string2,string3'
        end
        context "set value globally but set nil locally" do
          let(:global_settings) { lambda{ __send__("set_#{key}", ['string1', 'string2']) } }
          let(:local_settings) { lambda{ __send__("set_#{key}", nil) } }
          it_behaves_like "without header", header
        end
      end
    end
  end

  DATETIME_SETTINGS = {
    send_at:       'X-MC-SendAt',
  }
  DATETIME_SETTINGS.each do |key, header|
    describe "#{header} header" do
      context "no set" do
        it_behaves_like "without header", header
      end
      context "set by #set_#{key}" do
        let(:local_settings) { lambda{ __send__("set_#{key}", DateTime.new(2001, 1, 2, 3, 4, 5)) } }
        it_behaves_like "with header", header, '2001-01-02 03:04:05'
      end
      context "set by ::set_#{key}" do
        let(:global_settings) { lambda{ __send__("set_#{key}", DateTime.new(2001, 1, 2, 3, 4, 5)) } }
        it_behaves_like "with header", header, '2001-01-02 03:04:05'
      end
      context "set by both #set_#{key} and ::set_#{key}" do
        context "set value globally and set value locally" do
          let(:global_settings) { lambda{ __send__("set_#{key}", DateTime.new(2001, 1, 2, 3, 4, 5)) } }
          let(:local_settings) { lambda{ __send__("set_#{key}", DateTime.new(2001, 1, 2, 3, 4, 6)) } }
          it_behaves_like "with header", header, '2001-01-02 03:04:06'
        end
        context "set value globally but set nil locally" do
          let(:global_settings) { lambda{ __send__("set_#{key}", DateTime.new(2001, 1, 2, 3, 4, 5)) } }
          let(:local_settings) { lambda{ __send__("set_#{key}", nil) } }
          it_behaves_like "without header", header
        end
      end
    end
  end

  describe "X-MC-Track header" do
    header = "X-MC-Track"
    context "no set" do
      it_behaves_like "without header", header
    end
    context "set by #set_open_track" do
      let(:local_settings) { lambda{ set_open_track } }

      it_behaves_like "with header", 'X-MC-Track', 'opens'
    end
    context "set by #set_open_track" do
      let(:global_settings) { lambda{ set_open_track } }

      it_behaves_like "with header", 'X-MC-Track', 'opens'
    end
    context "set by #set_open_track" do
      let(:local_settings) { lambda{ set_click_track :all } }
      it_behaves_like "with header", 'X-MC-Track', 'clicks_all'
      context "invalid type" do
        let(:local_settings) { lambda{ set_click_track :invalid } }
        it_behaves_like "raise an exception", Mandriller::InvalidHeaderValue
      end
    end
    context "set by ::set_open_track" do
      let(:global_settings) { lambda{ set_click_track :all } }
      it_behaves_like "with header", 'X-MC-Track', 'clicks_all'
    end
    context "set by both ::set_open_track and ::set_click_track" do
      let(:global_settings) { lambda{ set_open_track; set_click_track :all } }
      it_behaves_like "with header", 'X-MC-Track', 'opens,clicks_all'
    end
  end

  describe "X-MC-Template header" do
    key = "template"
    header = "X-MC-Template"
    context "no set" do
      it_behaves_like "without header", header
    end
    context "set by #set_#{key}" do
      let(:local_settings) { lambda{ __send__("set_#{key}", 'template1', 'block1') } }
      it_behaves_like "with header", header, 'template1|block1'
    end
    context "set by ::set_#{key}" do
      let(:global_settings) { lambda{ __send__("set_#{key}", 'template1', 'block1') } }
      it_behaves_like "with header", header, 'template1|block1'
    end
    context "set by both #set_#{key} and ::set_#{key}" do
      context "set value globally and set value locally" do
        let(:global_settings) { lambda{ __send__("set_#{key}", 'template1', 'block1') } }
        let(:local_settings) { lambda{ __send__("set_#{key}", 'template2', 'block2') } }
        it_behaves_like "with header", header, 'tempalte2|block2'
      end
      context "set value globally but set nil locally" do
        let(:global_settings) { lambda{ __send__("set_#{key}", 'template1', 'block1') } }
        let(:local_settings) { lambda{ __send__("set_#{key}", nil) } }
        it_behaves_like "without header", header
      end
    end
  end
end
