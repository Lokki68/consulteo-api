class CabinetSerializer
  include Alba::Resource

  attributes :id, :name, :address, :city, :postal_code, :phone_number, :latitude, :longitude, :created_at, :updated_at
end