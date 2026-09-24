require "rails_helper"

RSpec.describe Stateful do
  describe "AASM integration" do
    let(:appointment) { create(:appointment) }

    it "starts in pending state" do
      expect(appointment.pending?).to be true
    end

    it "transitions from pending to confirmed" do
      expect { appointment.confirm! }.to change { appointment.status }.from("pending").to("confirmed")
    end

    it "raises on invalid transition" do
      appointment.completed!
      expect { appointment.confirm! }.to raise_error(AASM::InvalidTransition)
    end
  end
end