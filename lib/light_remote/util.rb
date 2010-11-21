
Time.class_eval do
  # Weekend cutoff is 5pm Friday to 5pm Sunday.
  def weekend?
    wday == 6 || wday == 0 && hour < 17 || wday == 5 && hour >= 17
  end

  def weekday?
    ! weekend?
  end
end
