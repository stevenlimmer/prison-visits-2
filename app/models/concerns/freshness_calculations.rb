module FreshnessCalculations
  def older_than(date)
    where(arel_table[:created_at].lt(date))
  end
end
