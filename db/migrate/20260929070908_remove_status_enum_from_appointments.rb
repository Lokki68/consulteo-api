class RemoveStatusEnumFromAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :status_str, :string, default: 'pending', null: false

    reversible do |dir|
      dir.up do
        execute <<-SQL
            UPDATE appointments
            SET status_str = CASE status
                WHEN 0 THEN 'pending'
                WHEN 1 THEN 'confirmed'
                WHEN 2 THEN 'cancelled'
                ELSE 'pending'
            END
        SQL
      end
    end

    remove_column :appointments, :status
    rename_column :appointments, :status_str, :status
  end
end
