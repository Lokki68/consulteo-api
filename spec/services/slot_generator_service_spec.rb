require 'rails_helper'

RSpec.describe SlotGeneratorService do
  include ActiveSupport::Testing::TimeHelpers

  let(:practitioner) { create(:practitioner_profile) }

  describe '#call' do
    around do |example|
      travel_to(Date.new(2026, 9, 14)) { example.run }
    end

    context 'avec une règle simple sans exception' do
      before do
        create(:availability_rule,
               practitioner_profile: practitioner,
               day_of_week: 1,
               start_time: "09:00",
               end_time: "10:00",
               slot_duration_minutes: 20,
               valid_from: Date.new(2026, 1, 1)
        )
      end

      it 'génère les créneaux corrects pour un lundi' do
        monday = Date.new(2026, 9, 14) # à vérifier : le 15/09/2026 est un mardi
        service = described_class.new(practitioner_profile: practitioner, from_date: monday, to_date: monday)

        result = service.call

        expect(result[monday].size).to eq(3)
      end
    end
  end
end
