json.array!(@messages) do |message|
  json.extract! message, :id, :text, :receiver_name, :user_name
end


