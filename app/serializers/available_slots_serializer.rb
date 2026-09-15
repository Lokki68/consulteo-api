class AvailableSlotsSerializer
  def initialize(slots_by_date)
    @slots_by_date = slots_by_date
  end

  def as_json
    {
      slots: @slots_by_date.transform_values { |slots| slots.map { |slot| serialize_slot(slot) } }
    }
  end

  private

  def serialize_slot(slot)
    {
      start_time: slot.start_time.iso8601,
      end_time: slot.end_time.iso8601
    }
  end
end
