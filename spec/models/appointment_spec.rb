require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:scheduled_at) }
    it { is_expected.to validate_presence_of(:duration) }
    it { is_expected.to validate_numericality_of(:duration).is_greater_than(0) }

    it 'est valide avec des attributs valides' do
      appointment = build(:appointment)
      expect(appointment).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:practitioner_profile) }
    it { is_expected.to belong_to(:patient_profile) }

    # it { is_expected.to have_one(:consultation).dependent(:destroy) }
  end

  describe '#ends_at' do
    it 'retourne scheduled_at + duration en minutes' do
      appointment = build(:appointment, scheduled_at: Time.zone.parse("2026-09-15 10:00"), duration: 45)
      expected = Time.zone.parse("2026-09-15 10:45")
      expect(appointment.ends_at).to eq(expected)
    end
  end

  describe 'scopes' do
    describe '.active' do
      it 'exclut les rendez-vous annulés' do
        active_appt = create(:appointment, :confirmed)
        cancelled_appt = create(:appointment, :cancelled, practitioner_profile: active_appt.practitioner_profile, scheduled_at: active_appt.scheduled_at + 2.hours)

        expect(Appointment.active).to include(active_appt)
        expect(Appointment.active).not_to include(cancelled_appt)
      end
    end

    describe '.on_date' do
      it 'retourne les rendez-vous du jour donné' do
        date = Date.new(2026, 9, 20)
        appt_on_date = create(:appointment, scheduled_at: date.noon)
        appt_other_date = create(:appointment, scheduled_at: date + 1.days)

        expect(Appointment.on_date(date)).to include(appt_on_date)
        expect(Appointment.on_date(date)).not_to include(appt_other_date)
      end
    end
  end

  describe '#no_overap_for_practitioner' do
    let(:practitioner) { create(:practitioner_profile) }
    let(:scheduled_at) { Time.zone.parse("2026-09-15 10:00") }

    before do
      create(:appointment, practitioner_profile: practitioner, scheduled_at: scheduled_at, duration: 30)
    end

    it 'refues un rendez-vous qui chevauche un rendez-vous existant (même praticien)' do
      overlapping = build(:appointment, practitioner_profile: practitioner, scheduled_at: scheduled_at + 15.minutes, duration: 30)

      expect(overlapping).not_to be_valid
      expect(overlapping.errors[:base]).to include('Ce créneau chevauche un rendez-vous existant')
    end

    it 'accepte un rendez-vous juste après la fin du précédent' do
      adjacent = build(:appointment, practitioner_profile: practitioner, scheduled_at: scheduled_at + 30.minutes, duration: 30)

      expect(adjacent).to be_valid
    end

    it 'accepte un rendez-vous qui chevauche mais avec un autre praticien' do
      other_practitioner = create(:practitioner_profile)
      overlapping_other_practitioner = build(:appointment,
                                             practitioner_profile: other_practitioner,
                                             scheduled_at: scheduled_at + 15.minutes,
                                             duration: 30
      )

      expect(overlapping_other_practitioner).to be_valid
    end

    it 'ignore les rendez-vous annulés pour le chevauchement' do
      practitioner2 = create(:practitioner_profile)
      cancelled = create(:appointment, :cancelled,
                         practitioner_profile: practitioner2,
                         scheduled_at: scheduled_at,
                         duration: 30
      )

      new_appt = build(:appointment,
                       practitioner_profile: practitioner2,
                       scheduled_at: scheduled_at + 10.minutes,
                       duration: 30
      )

      expect(new_appt).to be_valid
    end
  end
end
