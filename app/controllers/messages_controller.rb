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
      digest = sha256.hexdigest(params[:timestamp] + params[:recipientname] + params[:name] + params[:cipher] + params[:iv] + params[:key_recipient_enc] + params[:sig_recipient])
      public_key = OpenSSL::PKey::RSA.new(Base64.decode64(User.find_by_name(params[:name]).public_key))
      decrypt_digest = public_key.public_decrypt(Base64.decode64(params[:sig_service]))

      if User.exists?(name: params[:recipientname]) then
        if decrypt_digest == digest and (Time.now.to_i - params[:timestamp].to_i) < 300 and (Time.now.to_i - params[:timestamp].to_i) >= 0  then
          @message = Message.new(message_params)
          @message.is_called = 0
          respond_to do |format|
            if @message.save
              format.json { render json: @success = '{"status":"1"}'}
            else
              format.json { render json: @success = '{"status":"2"}'}
            end
          end
        else
          respond_to do |format|
            format.json { render json: @success = '{"status":"2"}'}
          end
        end
      else
        respond_to do |format|
          format.json { render json: @success = '{"status":"3"}'}
        end
      end
    rescue Exception
      render json:  '{"status":"2"}'
    end
  end

  # GET /users/[name]/messages/
  def messages
    begin
      if !User.exists?(name: params[:id]) then
          render json: '{"status":"3"}' and return
      end

      sha256 = OpenSSL::Digest::SHA256.new
      digest = sha256.hexdigest(params[:id] + params[:timestamp])
      public_key = OpenSSL::PKey::RSA.new(Base64.decode64(User.find_by_name(params[:id]).public_key))
      decrypt_digest = public_key.public_decrypt(Base64.decode64(params[:signature]))

      if decrypt_digest == digest and (Time.now.to_i - params[:timestamp].to_i) < 300 and (Time.now.to_i - params[:timestamp].to_i) >= 0  then
        @messages = Message.where(recipientname: params[:id]).where(is_called: false).each
        @messages.each do |m|
          m.is_called = true
          m.save
        end
        respond_to do |format|
          format.json { render :index}
        end
      else
        respond_to do |format|
          format.json { render json: @success = '{"status":"2"}'}
        end
      end
    rescue Exception
      render json:  '{"status":"2"}'
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
