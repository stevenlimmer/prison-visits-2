class Cancellation < ActiveRecord::Base
  class Reason
    include ActiveModel::Model
    attr_accessor :explanation, :id, :label
  end
end
