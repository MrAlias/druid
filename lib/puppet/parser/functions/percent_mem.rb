module Puppet::Parser::Functions
  newfunction(:percent_mem, :arity => 1, :type => :rvalue, :doc => <<-EOS
    Return percentage of total memory.

    The first and only parameter is the percentage of memory to return, and
    is expected to be a number between 0 and 100.

    If the requested portion of memory is less than 256 MB, 256m is
    returned instead.  This behaviour is intended given Druid's expected
    memory requirements.
    EOS
  ) do |args|
	pct = Float(args[0])

	if not pct.between?(0, 100)
		raise(Puppet::ParseError, "percent_mem(): #{pct} is not in [0, 100]")
	end

    ratio = pct / 100.0
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
