module Puppet::Parser::Functions
  newfunction(:percent_mem, :type => :rvalue, :doc => <<-EOS
    Return percentage of total memory.

    The first and only parameter is the percentage of memory to return, and
    is expected to be a number between 0 and 100.

    If the requested portion of memory is less than 256 MB, 256m is
    returned instead.  This behaviour is intended given Druid's expected
    memory requirements.
    EOS
  ) do |args|
    raise(Puppet::ParseError, "percent_mem(): Wrong number of arguments " +
      "given (#{args.size} for 1)") if args.size != 1

    raise(Puppet::ParseError, "percent_mem(): Invalid argument type: " +
      "#{args[0]} is not a Numeric") if not args[0].is_a? Numeric

    raise(Puppet::ParseError, "percent_mem(): Invalid argument value: " +
      "#{args[0]} is not in [0, 100]") if not args[0].between?(0,100)

    ratio = args[0] / 100.0
    value, unit = lookupvar('memorysize').split(' ')
    num_bytes = {
      "kb" => 1024,
      "mb" => 1024**2,
      "gb" => 1024**3,
      "tb" => 1024**4,
      "pb" => 1024**5,
      "eb" => 1024**6,
      "zb" => 1024**7,
      "yb" => 1024**8
    }[unit.downcase]

    bytes = num_bytes * value.to_f * ratio
    if bytes < 268435456
      retval = '256m'
    else 
      retval = (bytes / num_bytes).round.to_s + unit[0].downcase
    end
    retval
  end
end
