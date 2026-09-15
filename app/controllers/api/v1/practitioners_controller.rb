module Api
  module V1
    class PractitionersController < ApplicationController
      def available_slots
        practitioner_profile = PractitionerProfile.find(params[:id])

        from_date = parse_date(params[:from_date]) || Date.current
        to_date = parse_date(params[:to_date]) || from_date + 6.days

        validate_date_range!(from_date, to_date)

        slots = SlotGeneratorService.new(
          practitioner_profile: practitioner_profile,
          from_date: from_date,
          to_date: to_date
        ).call

        render json: AvailableSlotsSerializer.new(slots).as_json, status: :ok

      rescue AvailableSlotsService::InvalidDateError => e
        render json: {
          error: e.message
        }, status: :unprocessable_entity
      end

      private

      def parse_date(date_param)
        return nil if date_param.blank?

        Date.parse(date_param)
      rescue Date::Error
        raise ArgumentError, "Format de date invalide (attendu: YYYY - MM - DD)"
      end

      def validate_date_range!(from_date, to_date)
        raise ArgumentError, "to_date doit etre après from_date" if to_date < from_date
        raise ArgumentError, "La plage ne peut pas dépasser 60 jours" if (to_date - from_date).to_i > 60
      end
    end
  end
end
