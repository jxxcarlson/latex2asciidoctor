

class Date

  # today.time_interval_for_days(2)
  # ==>Today...Today + 2
  # today.time_interval_for_days(-7)
  # ==>Today...Today - 7
  def time_interval_for_days(days)
    # return a range from days_before a date to a_date
    raise ArgumentError, "expected 'self' to be a Date" unless self.is_a? Date
    date_now_start = Time.new(self.year, self.month, self.day, 0, 0, 0).utc
    date_now_end = Time.new(self.year, self.month, self.day , 23, 59, 59).utc
    if days >= 0
      date_after_end = date_now_end + days*24*60*60
      puts "date_now_start #{date_now_start}".yellow
      puts "date_after_end #{date_after_end}".yellow
      return (date_now_start...date_after_end)
    else
      date_before_start = date_now_start  + days*24*60*60
      puts "date_now_end #{date_now_end}".yellow
      puts "date_before_start #{date_before_start}".yellow
      return (date_before_start...date_now_end)
    end

  end

end

class String

  def blue
    "\e[1;34m#{self}\e[0m"
  end

  def green
    "\e[1;32m#{self}\e[0m"
  end

  def red
    "\e[1;31m#{self}\e[0m"
  end

  def yellow
    "\e[1;33m#{self}\e[0m"
  end

  def magenta
    "\e[1;35m#{self}\e[0m"
  end

  def cyan
    "\e[1;36m#{self}\e[0m"
  end

  def white
    "\e[1;37m#{self}\e[0m"
  end

  def black
    "\e[1;30m#{self}\e[0m"
  end

end


