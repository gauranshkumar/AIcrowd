require 'rails_helper'

describe Discourse::FetchChallengePostsService, :requests_allowed do
  subject { described_class.new(challenge: challenge) }

  let(:challenge) { create(:challenge, :running, discourse_category_id: 2) }

  describe '#call' do
    context 'when discourse ENV variables are missing' do
      before { ENV.stub(:[]).with('DISCOURSE_DOMAIN_NAME').and_return('') }

      it 'returns failure' do
        result = subject.call

        expect(result.success?).to eq false
        expect(result.value).to eq 'Discourse API client couldn\'t be properly initialized.'
      end
    end

    context 'when discourse ENV variables are set' do
      it 'returns success and list of user posts' do
        result = VCR.use_cassette('discourse_api/data_explorer_queries/challenge_posts/success') do
          subject.call
        end

        expect(result.success?).to eq true

        response = result.value

        expect(response.size).to eq 4
        expect(response.first['cooked']).to eq '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit 2.</p>'
      end
    end

    context 'when discourse API is unavailable' do
      before do
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_raise(Discourse::Error)
      end

      it 'returns failure' do
        result = subject.call

        expect(result.success?).to eq false
        expect(result.value).to eq 'Discourse API is unavailable.'
      end
    end
  end
end
