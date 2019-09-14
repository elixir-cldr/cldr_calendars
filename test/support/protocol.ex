# This is a test implementation to override the standard
# implementation in testing of "older" releases
if Version.compare(System.version(), "1.10.0-dev") == :lt do
  defimpl Inspect, for: Date do
    def inspect(date, opts) do
      Cldr.Calendar.inspect(date, opts)
    end
  end
end
