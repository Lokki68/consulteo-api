class AddFieldsToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :consultation_type, :integer, default: 0, null: false
    add_column :appointments, :notes, :text
    add_column :appointments, :cancelled_at, :datetime
    add_column :appointments, :reschedule_reason, :text
    add_column :appointments, :price_cents, :integer, precision: 8, scale: 2, null: false, default: 0
    add_column :appointments, :payment_status, :integer, default: 0, null: false

    add_reference :appointments, :cancelled_by_user, type: :uuid, foreign_key: { to_table: :users }

    add_index :appointments, :payment_status
  end
end
