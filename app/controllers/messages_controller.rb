class MessagesController < ApplicationController
  before_action :set_message, only: [:show]
  skip_before_filter :verify_authenticity_token

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.all
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
  end

  # POST /messages
  # POST /messages.json
  def create
    begin
      sha256 = OpenSSL::Digest::SHA256.new
      # sig_service berechnen
      digest = sha256.hexdigest(params[:timestamp].to_s + params[:recipientname].to_s + params[:name].to_s + params[:cipher].to_s + params[:iv].to_s + params[:key_recipient_enc].to_s + params[:sig_recipient].to_s)
      # public_key des Users aus der Datenbank holen
      public_key = OpenSSL::PKey::RSA.new(Base64.decode64(User.find_by_name(params[:name]).public_key))
      # sig_service vom Client entschlüsseln
      decrypt_digest = public_key.public_decrypt(Base64.decode64(params[:sig_service]))
      # Prüfen ob der Empfänger existiert
      if User.exists?(name: params[:recipientname]) then
        # sig_service überprüfen
        if decrypt_digest == digest then
          # Überprüfen ob Nachricht nicht älter als fünf Minuten
          if (Time.now.to_i - params[:timestamp].to_i) < 300 and (Time.now.to_i - params[:timestamp].to_i) >= 0  then
            @message = Message.new(message_params)
            @message.is_called = 0
            respond_to do |format|
              # Nachricht speichern
              if @message.save
                format.json { render json: '{"status":"1"}'}
              else
                format.json { render json: '{"status":"2"}'}
              end
            end
          else
            respond_to do |format|
              format.json { render json: '{"status":"4"}'}
            end
          end
        else
          respond_to do |format|
            format.json { render json: '{"status":"5"}'}
          end
        end
      else
        respond_to do |format|
          format.json { render json: '{"status":"3"}'}
        end
      end
    rescue Exception => e
      render json: '{"status":"99"}'
    end
  end

  # GET /users/[name]/messages/
  def messages
    begin
      # Überprüfen ob User existiert
      if !User.exists?(name: params[:id]) then
          render json: '{"status":"3"}' and return
      end

      sha256 = OpenSSL::Digest::SHA256.new
      # signature berechnen
      digest = sha256.hexdigest(params[:id] + params[:timestamp].to_s)
      # public_key des Users aus der Datenbank holen
      public_key = OpenSSL::PKey::RSA.new(Base64.decode64(User.find_by_name(params[:id]).public_key))
      # signature vom Client mit public_key entschlüsseln
      decrypt_digest = public_key.public_decrypt(Base64.decode64(params[:signature]))
      # signature überprüfen
      if decrypt_digest == digest then
        # Überprüfen ob Nachricht nicht älter als fünf Minuten
        if (Time.now.to_i - params[:timestamp].to_i) < 300 and (Time.now.to_i - params[:timestamp].to_i) >= 0  then
          # Alle neuen Nachrichten des Users abrufen.
          @messages = Message.where(recipientname: params[:id]).where(is_called: false)
          # Wenn keine gefunden, dann Status 5 zurückgeben, sonst Nachrichten zurückgeben
          if(@messages.blank?)
            respond_to do |format|
              format.json { render json: '{"status":"5"}'}
            end
          else
            @messages.each do |m|
              m.is_called = true
              m.save
            end
            respond_to do |format|
              format.json { render json: @messages}
            end
          end
        else
          respond_to do |format|
            format.json { render json: '{"status":"4"}'}
          end
        end
      else
        respond_to do |format|
          format.json { render json: '{"status":"2"}'}
        end
      end
    rescue Exception => e
      render json: '{"status":"99"}'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:timestamp, :recipientname, :sig_service, :name, :cipher, :iv, :key_recipient_enc, :sig_recipient, :signature)
    end

end
