json.array!(@users) do |user|
  json.extract! user, :id, :name, :public_key, :private_key, :salt_master_key
end
