json.array!(@messages) do |message|
  json.extract! message, :name, :cipher, :iv, :key_recipient_enc, :sig_recipient
end
