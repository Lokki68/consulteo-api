require 'rails_helper'

RSpec.describe Appointment, type: :model do
  let(:practitioner) { create :practitioner_profile }
  let(:patient) { create :patient_profile }
  let(:appointment) { create(:appointment, practitioner_profile: practitioner, patient_profile: patient)}

  describe 'associations' do
    it { is_expected.to belong_to(:practitioner_profile) }
    it { is_expected.to belong_to(:patient_profile) }
    it { is_expected.to belong_to(:cancelled_by_user).class_name('User').optional }

    # it { is_expected.to have_one(:consultation).dependent(:destroy) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:consultation_type).with_values(in_person: 0, video: 1, phone: 2) }
    it { is_expected.to define_enum_for(:payment_status).with_values(unpaid: 0, paid: 1, refunded: 2, partially_paid: 3) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:scheduled_at) }
    it { is_expected.to validate_presence_of(:duration) }
    it { is_expected.to validate_numericality_of(:duration).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:price_cents) }
    it { is_expected.to validate_numericality_of(:price_cents).is_greater_than_or_equal_to(0) }

    it 'est valide avec des attributs valides' do
      appointment = build(:appointment)
      expect(appointment).to be_valid
    end
  end

  describe '#ends_at' do
    it 'retourne scheduled_at + duration en minutes' do
      appointment = build(:appointment, scheduled_at: Time.zone.parse("2026-09-15 10:00"), duration: 45)
      expected = Time.zone.parse("2026-09-15 10:45")
      expect(appointment.ends_at).to eq(expected)
    end

    it 'calculate correctly for different durations' do
      appointment.update(duration: 60)
      expect(appointment.ends_at).to eq(appointment.scheduled_at + 60.minutes)
    end
  end

  describe '#prices' do
    it 'converts price cents to decimal' do
      appointment.update(price_cents: 5000)
      expect(appointment.price).to eq(50.0)
    end

    it 'handles zero price' do
      appointment.update(price_cents: 0)
      expect(appointment.price).to eq(0.0)
    end
  end

  describe 'state_machine' do
    let(:appointment) { create(:appointment) }

    it 'Start in pending state' do
      expect(appointment).to be_pending
    end

    it 'transition to confirmed' do
      appointment.confirm!
      expect(appointment.reload).to be_confirmed
    end

    it 'transition to cancelled' do
      appointment.cancel!
      expect(appointment.reload).to be_cancelled
    end

    it 'transition to completed' do
      appointment.confirm!
      appointment.complete!
      expect(appointment.reload).to be_completed
    end

    # it 'transition to no_show' do
    #   appointment.confirm!
    #   appointment.mark_no_show
    #   expect(appointment.reload).to be_no_show
    # end
  end

  describe '#cancellable?' do
    let(:practitioner_with_deadline) { create(:practitioner_profile, cancellation_deadline_hours: 24) }

    context 'when appointment us in the future with enough time' do
      it 'returns true' do
        future_appointment = create(:appointment, practitioner_profile: practitioner_with_deadline, patient_profile: patient, scheduled_at: 48.hours.from_now, status: :confirmed)

        expect(future_appointment.cancellable?).to be true
      end
    end

    context 'when appointment is within cancellation deadline' do
      it 'returns false' do
        soon_appointment = create(:appointment, practitioner_profile: practitioner_with_deadline, patient_profile: patient, scheduled_at: 12.hours.from_now, status: :confirmed)

        expect(soon_appointment.cancellable?).to be false
      end
    end

    context 'when appointment is already cancelled' do
      it 'returns false' do
        cancelled_appointment = create(:appointment, :cancelled, practitioner_profile: practitioner, patient_profile: patient)

        expect(cancelled_appointment.cancellable?).to be false
      end
    end

    context 'when appointment is no_show' do
      it 'returns false' do
        no_show_appointment = create(:appointment, practitioner_profile: practitioner, patient_profile: patient, status: :no_show)

        expect(no_show_appointment.cancellable?).to be false
      end
    end
  end

  describe '#cancel_with_reason!' do
    let(:user) { create(:user) }
    let(:practitioner_with_deadline) { create(:practitioner_profile, cancellation_deadline_hours: 24) }
    let(:cancellable_appointment) do
      create(:appointment,
             practitioner_profile: practitioner_with_deadline,
             patient_profile: patient,
             scheduled_at: 48.hours.from_now,
             status: :confirmed
      )
    end

    context 'when appointment is cancellable' do
      it 'changed status to cancelled' do
        cancellable_appointment.cancel_with_reason!(by: user, reason: 'patient request')
        expect(cancellable_appointment.reload).to be_cancelled
      end

      it 'sets cancelled_by_user' do
        user = create(:user)
        cancellable_appointment.cancel_with_reason!(by: user, reason: 'patient request')

        expect(cancellable_appointment.cancelled_by_user).to eq(user)
      end

      it 'sets cancelled_at' do
        cancellable_appointment.cancel_with_reason!(by: user, reason: 'patient request')
        expect(cancellable_appointment.reload.cancelled_at).to be_present
      end

      it 'sets cancellation_reason' do
        cancellable_appointment.cancel_with_reason!(by: user, reason: 'patient request')
        expect(cancellable_appointment.reload.cancellation_reason).to eq("patient request")
      end
    end

    let!(:non_cancellable_appointment) { create(:appointment, :cancelled, practitioner_profile: practitioner, patient_profile: patient) }

    context 'when appointment is not cancellable' do
      it 'raise NotCancellableError' do
        expect do
          non_cancellable_appointment.cancel_with_reason!(by: user, reason: 'patient request')
        end.to raise_error(Appointment::NotCancellableError)
      end
    end
  end

  describe '#reschedule!' do
    let(:practitioner_with_deadline) { create(:practitioner_profile, cancellation_deadline_hours: 24) }
    let(:reschedulable_appointment) { create(:appointment,
                                             practitioner_profile: practitioner_with_deadline,
                                             patient_profile: patient,
                                             scheduled_at: 48.hours.from_now,
                                             status: :confirmed
    ) }
    let(:non_reschedulable_appointment) { create(:appointment,
                                                 practitioner_profile: practitioner,
                                                 patient_profile: patient,
                                                 scheduled_at: 12.hours.from_now,
                                                 status: :confirmed
                                                 ) }

    let(:new_scheduled_at)  do
      3.days.from_now.change(hour: 14, min: 0, sec: 0, usec: 0)
    end

    before do
      reschedulable_appointment.reschedule!(new_scheduled_at: new_scheduled_at, reason: 'patient request')
    end

    context 'when appointment is reschedulable' do
      it 'updates scheduled_at' do
        expect(reschedulable_appointment.reload.scheduled_at).to eq(new_scheduled_at)
      end

      it 'sets status to pending' do
        expect(reschedulable_appointment.reload.status).to eq('pending')
      end

      it 'sets reschedule_reason' do
        expect(reschedulable_appointment.reload.reschedule_reason).to eq('patient request')
      end
    end

    context 'when appointment is not reschedulable' do
      it 'raise NotCancellableError' do
        expect do
          non_reschedulable_appointment.reschedule!(new_scheduled_at: new_scheduled_at,reason: 'patient request')
        end.to raise_error(Appointment::NotCancellableError)
      end
    end
  end

  describe '#no_overlap_for_practitioner' do
    let(:base_time) { 2.days.from_now.change(hour: 10, min: 0, sec: 0) }
    let(:practitioner) { create(:practitioner_profile) }
    let(:patient_1) { create(:patient_profile) }
    let(:patient_2) { create(:patient_profile) }

    context 'when creating an appointment that overlaps' do
      before do
        # ✅ Crée UN appointment existant
        create(:appointment,
               practitioner_profile: practitioner,
               patient_profile: patient_1,
               scheduled_at: base_time,
               duration: 30
        )
      end

      it 'raise validation error' do
        # ✅ Essaie d'en créer un qui chevauche
        overlapping_appointment = build(:appointment,
                                        practitioner_profile: practitioner,
                                        patient_profile: patient_2,  # ✅ PATIENT DIFFÉRENT
                                        scheduled_at: base_time + 15.minutes,
                                        duration: 30
        )

        expect(overlapping_appointment).not_to be_valid
        expect(overlapping_appointment.errors[:base]).to include('Ce créneau chevauche un rendez-vous existant')
      end
    end

    context 'when appointment does not overlap' do
      before do
        create(:appointment,
               practitioner_profile: practitioner,
               patient_profile: patient_1,
               scheduled_at: base_time,
               duration: 30
        )
      end

      it 'allows the appointment' do
        non_overlapping = build(:appointment,
                                practitioner_profile: practitioner,
                                patient_profile: patient_2,
                                scheduled_at: base_time + 1.hour,  # ✅ 1 heure après
                                duration: 30
        )

        expect(non_overlapping).to be_valid
      end
    end

    context 'when another practitioner has an appointment at the same time' do
      let(:other_practitioner) { create(:practitioner_profile) }

      before do
        create(:appointment,
               practitioner_profile: other_practitioner,
               patient_profile: patient_1,
               scheduled_at: base_time,
               duration: 30
        )
      end

      it 'allows the appointment' do
        appointment = build(:appointment,
                            practitioner_profile: practitioner,  # ✅ PRATICIEN DIFFÉRENT
                            patient_profile: patient_2,
                            scheduled_at: base_time,
                            duration: 30
        )

        expect(appointment).to be_valid
      end
    end
  end



  describe 'scopes' do
    let(:practitioner) { create(:practitioner_profile) }
    let(:patient) { create(:patient_profile) }

    describe '.active' do
      let!(:active_appointment) { create(:appointment, practitioner_profile: practitioner, patient_profile: patient) }
      let!(:cancelled_appointment) { create(:appointment, :cancelled, practitioner_profile: practitioner, patient_profile: patient) }

      it 'excludes cancelled_appointment ' do
        expect(Appointment.active.count).to eq(1)
        expect(Appointment.active).not_to include(cancelled_appointment)
      end
    end

    describe '.on_date' do
      let(:target_date) { Date.tomorrow }

      let!(:on_date_appointment) { create(:appointment, practitioner_profile: practitioner, patient_profile: patient, scheduled_at: target_date.change(hour: 10)) }
      let!(:not_on_date_appointment) { create(:appointment, practitioner_profile: practitioner, patient_profile: patient, scheduled_at: target_date + 1.day) }

      it 'returns on_date_appointment on target_date' do
        result = Appointment.on_date(target_date)

        expect(result.count).to eq(1)
        expect(result).to include(on_date_appointment)
      end

      it 'excludes not_on_date_appointment' do
        result = Appointment.on_date(target_date)

        expect(result).not_to include(not_on_date_appointment)
      end
    end

    describe '.upcoming' do
      let!(:future_appointment) { create(:appointment,
                                        practitioner_profile: practitioner,
                                        patient_profile: patient,
                                        scheduled_at: 1.day.from_now
      ) }
      let!(:past_appointment) { create(:appointment,
                                       practitioner_profile: practitioner,
                                       patient_profile: patient,
                                       scheduled_at: 1.day.ago
      ) }

      it 'return only future_appointment' do
        result = Appointment.upcoming

        expect(result.count).to eq(1)
        expect(result).to include(future_appointment)
      end
    end

    describe '.past' do
      let!(:futur_appointment) { create(:appointment,
                                        practitioner_profile: practitioner,
                                        patient_profile: patient,
                                        scheduled_at: 1.day.from_now
      ) }
      let!(:past_appointment) { create(:appointment,
                                       practitioner_profile: practitioner,
                                       patient_profile: patient,
                                       scheduled_at: 1.day.ago
      ) }

      it 'return only past_appointment' do
        result = Appointment.past

        expect(result.count).to eq(1)
        expect(result).to include(past_appointment)
      end
    end

    describe '.for_patient' do
      let(:patient_2) { create(:patient_profile) }

      let!(:patient_appointment) { create(:appointment, practitioner_profile: practitioner, patient_profile: patient) }
      let!(:patient_2_appointment) { create(:appointment, practitioner_profile: practitioner, patient_profile: patient_2) }

      it 'return appointment for the specifique patient' do
        result = Appointment.for_patient(patient.id)

        expect(result.count).to eq(1)
        expect(result.first.patient_profile).to eq(patient)
      end
    end

    describe '.for_practitioner' do
      let(:practitioner_2) { create(:practitioner_profile) }

      let!(:practitioner_appointment) { create(:appointment, practitioner_profile: practitioner, patient_profile: patient) }
      let!(:practitioner_2_appointment) { create(:appointment, practitioner_profile: practitioner_2, patient_profile: patient) }

      it 'return appointment for the specifique practitioner' do
        result = Appointment.for_practitioner(practitioner.id)

        expect(result.count).to eq(1)
        expect(result.first.practitioner_profile).to eq(practitioner)
      end
    end
  end
end
