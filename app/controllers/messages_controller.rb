class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]
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

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  # POST /messages.json
  def create

    sha256 = OpenSSL::Digest::SHA256.new
    digest = sha256.digest(params[:timestamp] + params[:recipientname] + params[:name] + params[:cipher] + params[:iv] + params[:key_recipient_enc] + params[:sig_recipient])
    public_key = OpenSSL::PKey::RSA.new(User.find_by_name(params[:name]).public_key)
    decrypt_digest = public_key.public_decrypt(params[:sig_service])

    if User.find_by_name(params[:recipientname]).exists? then
      if digest = decrypt_digest and (:date.to_time.to_i - params[:timestamp]) < 300 and (:date.to_time.to_i - params[:timestamp]) > 0  then
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
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.json { render :show, status: :ok, location: @message }
      else
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /users/[name]/messages/
  def messages

    if !User.exists?(name: params[:id]) then
        render json: '{"status":"3"}' and return
    end

    sha256 = OpenSSL::Digest::SHA256.new
    digest = sha256.digest(params[:name] + params[:timestamp])
    public_key = OpenSSL::PKey::RSA.new(User.find_by_name(params[:id]).public_key)
    decrypt_digest = public_key.public_decrypt(params[:signature])

    if digest = decrypt_digest and (:date.to_time.to_i - params[:timestamp]) < 300 and (:date.to_time.to_i - params[:timestamp]) > 0  then
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

  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.destroy
    respond_to do |format|
      format.json { head :no_content }
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
