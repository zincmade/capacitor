# frozen_string_literal: true

require "time"

# Time of any abstract day, represented hour-by-hour;
# e.g. *any* 12 PM, not 12 PM, December 3, 2017
class TimeOfDay
  include Comparable

  def self.from_string(string)
    hour_of_day = hour_of_day_from_string(string)
    new(hour_of_day: hour_of_day)
  end

  def self.from_hour_of_day(hour_of_day)
    hour_of_day = Integer(hour_of_day)
    raise RangeError unless (0..23).cover?(hour_of_day)
    new(hour_of_day: hour_of_day)
  end

  def self.from_time(time)
    new(hour_of_day: time.hour)
  end

  def self.hour_of_day_from_string(string)
    # rubocop:disable Rails/TimeZone
    Time.parse(string).hour
    # rubocop:enable Rails/TimeZone
  end

  def self.acceptable_values
    (0..23).map { |hour| from_hour_of_day(hour) }
  end

  attr_reader :hour_of_day

  def initialize(hour_of_day:)
    @hour_of_day = hour_of_day
  end

  def as_string
    # rubocop:disable Rails/TimeZone
    Time.new(1, 1, 1, hour_of_day).to_s(:hour_of_day)
    # rubocop:enable Rails/TimeZone
  end

  def to_s
    as_string
  end

  def to_time_of_day
    self
  end

  def ==(other)
    other.is_a?(TimeOfDay) && other.hour_of_day == hour_of_day
  end

  def <=>(other)
    return nil unless other.is_a?(TimeOfDay)
    hour_of_day <=> other.hour_of_day
  end

  def succ
    raise NotImplementedError if hour_of_day == 23
    self.class.from_hour_of_day(hour_of_day + 1)
  end

  def inspect
    "TimeOfDay<#{as_string}>"
  end
end

# rubocop:disable Style/MethodName
def TimeOfDay(input)
  if input.respond_to?(:to_time_of_day)
    input.to_time_of_day
  else
    TimeOfDay.from_string(input)
  end
end
# rubocop:enable Style/MethodName
