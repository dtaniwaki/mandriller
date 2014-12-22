deliver_method = ActionMailer.respond_to?(:version) && ActionMailer.version.to_s.to_f >= 4.2 ? :deliver_now! : :deliver!
shared_examples "with header" do |header, value|
  it "sets header #{header}" do
    expect {
      subject.__send__(deliver_method)
    }.to change { ActionMailer::Base.deliveries.count }.by(1)
    m = ActionMailer::Base.deliveries.last
    expect(m.header.to_s).to match(/(\r\n)?#{header}: #{value}(\r\n)?/)
  end
end
shared_examples "without header" do |header|
  it "does not set header #{header}" do
    expect {
      subject.__send__(deliver_method)
    }.to change { ActionMailer::Base.deliveries.count }.by(1)
    m = ActionMailer::Base.deliveries.last
    expect(m.header.to_s).not_to match(/(\r\n)?#{header}: [^\r]*(\r\n)?/)
  end
end
shared_examples "raise an exception" do |exception|
  it "raises #{exception}" do
    expect {
      expect {
        subject.__send__(deliver_method)
      }.to raise_error(exception)
    }.to change { ActionMailer::Base.deliveries.count }.by(0)
  end
end
