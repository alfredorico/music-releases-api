# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Releases::ListService do
  describe '#call' do
    context 'when fetching data successfully' do
      context 'with past parameter' do
        let!(:past_releases) { FactoryBot.create_list(:release, 3, :past) }
        let!(:upcoming_releases) { FactoryBot.create_list(:release, 2, :upcoming) }

        context 'when past is nil' do
          subject(:result) { described_class.new.call }

          it 'returns a successful result' do
            expect(result).to be_success
          end

          it 'returns all releases' do
            expect(result.data.records.count).to eq(5)
          end
        end

        context 'when past is "1"' do
          subject(:result) { described_class.new(past: '1').call }

          it 'returns a successful result' do
            expect(result).to be_success
          end

          it 'returns only past releases' do
            expect(result.data.records.count).to eq(3)
            expect(result.data.records).to match_array(past_releases)
          end
        end

        context 'when past is "0"' do
          subject(:result) { described_class.new(past: '0').call }

          it 'returns a successful result' do
            expect(result).to be_success
          end

          it 'returns only upcoming releases' do
            expect(result.data.records.count).to eq(2)
            expect(result.data.records).to match_array(upcoming_releases)
          end
        end
      end

      context 'with pagination parameters' do
        let!(:releases) { FactoryBot.create_list(:release, 15, :past) }

        context 'when using default pagination' do
          subject(:result) { described_class.new.call }

          it 'returns the default limit of records' do
            expect(result.data.records.count).to eq(10)
          end

          it 'returns correct pagination metadata' do
            expect(result.data.metadata[:total_count]).to eq(15)
            expect(result.data.metadata[:total_pages]).to eq(2)
            expect(result.data.metadata[:current_page]).to eq(1)
          end
        end

        context 'when specifying limit' do
          subject(:result) { described_class.new(limit: 5).call }

          it 'returns the specified number of records' do
            expect(result.data.records.count).to eq(5)
          end

          it 'returns correct pagination metadata' do
            expect(result.data.metadata[:per_page]).to eq(5)
            expect(result.data.metadata[:total_pages]).to eq(3)
          end
        end

        context 'when specifying page' do
          subject(:result) { described_class.new(page: 2, limit: 5).call }

          it 'returns records from the specified page' do
            expect(result.data.records.count).to eq(5)
            expect(result.data.metadata[:current_page]).to eq(2)
          end
        end
      end
    end

    context 'when fetching data fails' do
      context 'when an exception is raised' do
        before do
          allow(Release).to receive(:includes).and_raise(StandardError, 'Database error')
        end

        subject(:result) { described_class.new.call }

        it 'returns a failure result' do
          expect(result).to be_failure
        end

        it 'returns an error message' do
          expect(result.error).to eq('An error occurred while fetching releases')
        end

        it 'logs the error' do
          expect(Rails.logger).to receive(:error).with('Releases::ListService error: Database error')
          result
        end
      end
    end
  end
end
