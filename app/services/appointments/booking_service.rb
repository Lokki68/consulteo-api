module Appointments
  class BookingService
    class SlotUnavailableError < StandardError; end

    def initialize(patient_profile:, practitioner_profile:, scheduled_at:, duration:, consultation_type:, notes: nil)
      @patient_profile = patient_profile
      @practitioner_profile = practitioner_profile
      @scheduled_at = scheduled_at
      @duration = duration
      @consultation_type = consultation_type
      @notes = notes
    end

    def call
      validate_slot_availability!

      appointment = Appointment.new(
        patient_profile: @patient_profile,
        practitioner_profile: @practitioner_profile,
        scheduled_at: @scheduled_at,
        duration: @duration,
        consultation_type: @consultation_type,
        notes: @notes,
        status: :pending,
        price_cents: @practitioner_profile.price_cents,
        payment_status: :unpaid
      )

      appointment.save!

      #TODO: Mailer (booking_confirmation / new_booking_notification)

      appointment
    end

    private

    def validate_slot_availability!
      requested_end_time = @scheduled_at + @duration.minutes
      date = @scheduled_at.to_date

      slots_by_date = SlotGeneratorService.new(
        practitioner_profile: @practitioner_profile,
        from_date: date,
        to_date: date
      )

      slot_match = (slot_by_date[date] || []).any? do |slot|
        slot.start_time == @scheduled_at && slot.end_time == requested_end_time
      end

      raise SlotUnavailableError, "Ce créneau n'est plus disponible" unless slot_match
    end
  end
end