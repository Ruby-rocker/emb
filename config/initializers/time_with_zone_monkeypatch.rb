class ActiveSupport::TimeWithZone
  # We want millisecond precision dates
  def as_json(options = nil)
    if ActiveSupport::JSON::Encoding.use_standard_json_time_format
      xmlschema(3)
    else
      %(#{time.strftime("%Y/%m/%d %H:%M:%S")} #{formatted_offset(false)})
    end
  end
end
