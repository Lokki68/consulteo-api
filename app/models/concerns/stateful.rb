module Stateful
  extend ActiveSupport::Concern

  included do
    include AASM
  end

  class_methods do
    def define_state_machine(&block)
      aasm(column: :status, &block)
    end
  end
end