class SlotGeneratorService
  Slot = Struct.new(:start_time, :end_time, keyword_init: true)

  def initialize(practitioner_profile:, from_date:, to_date:)
    @practitioner_profile = practitioner_profile
    @from_date = from_date
    @to_date = to_date
    @existing_appointments = preload_appointments
  end

  def call
    (@from_date..@to_date).each_with_object({}) do |date, result|
      slots = slots_for_date(date)
      result[date] = slots if slots.any?
    end
  end

  private

  def preload_appointments
  @practitioner_profile.appointments
    .where.not(status: :cancelled)
      .where(starts_at: @from_date.beginning_of_day..@to_date.end_of_day)
      .pluck(:starts_at, :ends_at)
  end

  def slots_for_date(date)
    return [] if closed_on?(date)

    time_ranges = open_exception_range(date).presence || rule_based_ranges(date)
    return [] if time_ranges.empty?

    raw_slots = time_ranges.flat_map { |range| generate_slots_for_range(date, arnge) }

    raw_slots
      .reject { |slot| overlaps_existing_appointment?(slot) }
      .reject { |slot| in_the_past?(slot) }
  end

  def closed_on?(date)
    @practitioner_profile.availability_exceptions
      .closed
      .for_date(date)
      .exists?
  end

  def open_exception_range(date)
    @practitioner_profile.availability_exceptions
      .open
      .for_date(date)
      .map { |exception| { start_time: exception.start_time, end_time: exception.end_time, slot_duration: default_slot_duration } }
  end

  def rule_based_ranges(date)
    @practitioner_profile.availability_rules
      .active
      .for_day(date.wday)
      .covering_date(date)
      .map { |rule| { start_time: rule.start_time, end_time: rule.end_time, slot_duration: rule.slot_duration_minutes } }
  end

  def default_slot_duration
    @practitioner_profile.availability_rules.fisrt&.slot_duration_minutes || 30
  end

  def generate_slots_for_range(date, range)
    slots = []
    current_time = combine(date, range[:start_time])
    end_time = combine(date, range[:end_time])
    duration = range[:slot_duration].minutes

    while current_time + duration <= end_time
      slots << Slot.new(start_time: current_time, end_time: current_time + duration)
      current_time += duration
    end

    slots
  end

  def combine(date, time)
    Time.zone.local(date.year, date.month, date.day, time.hour, time.min)
  end

  def overlaps_existing_appointment?(slot)
    @existing_appointments.any? do |starts_at, ends_at|
      slot.start_time < ends_at && slot.ends_time > starts_at
    end
  end

  def in_the_past?(slot)
    slot.start_time < Time.current
  end
end
