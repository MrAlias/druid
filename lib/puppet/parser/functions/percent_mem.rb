module Puppet::Parser::Functions
  newfunction(:percent_mem, :arity => -2, :type => :rvalue, :doc => <<-EOS
    Return percentage of total memory.

    The first parameter is the percentage of memory to return, and is
    expected to be a number between 0 and 100.

    The second parameter specifies the minimum memory amount to return.
    If the computed percentage is less then this value this value is
    returned. This value is expected to be in the same JVM form that this
    function returns (i.e. 5g, 128m, 256k).  This defaults to 256m.
    EOS
  ) do |args|
    pct = Float(args[0])

    if not pct.between?(0, 100)
      raise(Puppet::ParseError, "percent_mem(): #{pct} is not in [0, 100]")
    end

    prefixes = {
      "kb" => 1024,
      "mb" => 1024**2,
      "gb" => 1024**3,
      "tb" => 1024**4,
      "pb" => 1024**5,
      "eb" => 1024**6,
      "zb" => 1024**7,
      "yb" => 1024**8
    }

    if args.size > 1
      min_val = Float(args[1][/^[0-9.]+/])
      min_unit = args[1][/^[0-9.]+(.)/, 1].downcase + 'b'
      min_bytes = prefixes[min_unit] * min_val
    else
      min_val = 256.0
      min_unit = 'mb'
      min_bytes = 268435456
    end

    mem_size = lookupvar('memorysize')
    val = mem_size[/^[0-9.]+/].to_f
    unit = mem_size[/^[0-9.]+ (.*)$/, 1].downcase
    scale = prefixes[unit]
    bytes = scale * val * pct / 100.0

    if bytes < min_bytes
      retval = min_val.round.to_s + min_unit[0]
    else 
      prefixes.select{|p,v| v <= scale}.sort_by{|p,v| -v}.each do |p,v|
        scaled = (bytes / v).round
        if scaled != 0
          retval = scaled.to_s + p[0]
          break
        end
      end
    end

    retval

  end
end
