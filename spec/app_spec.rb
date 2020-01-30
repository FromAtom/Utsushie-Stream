describe App do
  describe "GET /" do
    before do
      get '/'
    end

    it 'response is ok' do
      expect(last_response).to be_ok
    end

    it "returns 'ok' message" do
      expect(last_response.body).to eq 'ok'

    end
  end

  describe "POST /" do
    subject { post "/", payload, { "CONTENT_TYPE" => "application/json" } }

    context "when url_verification" do
      let(:payload) { fixture("url_verification.json") }

      it { should be_ok }

      it 'response is ok' do
        json = JSON.parse(payload)
        challenge = json['challenge']
        require_json = {
          challenge: challenge
        }.to_json

        subject
        expect(last_response.body).to eq require_json
      end
    end

    context "add event called once" do
      let(:payload) { fixture("emoji_added.json") }

      it { should be_ok }

      it 'add_emoji method called' do
        allow(App).to receive(:add_emoji)
        subject
        expect(App).to have_received(:add_emoji).with('picard_facepalm', 'https://my.slack.com/emoji/picard_facepalm/db8e287430eaa459.gif')
      end
    end

    context "add event called twice" do
      let(:payload) { fixture("emoji_added.json") }

      it { should be_ok }

      it "add_emoji method is called once" do
        allow(App).to receive(:add_emoji)
        subject
        subject
        expect(App).to have_received(:add_emoji).with('picard_facepalm', 'https://my.slack.com/emoji/picard_facepalm/db8e287430eaa459.gif').once
      end
    end

    context "add alias event" do
      let(:payload) { fixture("emoji_alias_added.json") }

      it { should be_ok }

      it "add_emoji_alias method is called" do
        allow(App).to receive(:add_emoji_alias)
        subject
        expect(App).to have_received(:add_emoji_alias).with('picard_facepalm_alias', 'picard_facepalm')
      end
    end

    context "remove event" do
      let(:payload) { fixture("emoji_removed.json") }

      it { should be_ok }

      it "remove method is called" do
        allow(App).to receive(:remove_emoji)
        subject
        expect(App).to have_received(:remove_emoji).with('picard_facepalm')
      end
    end

  end
end
