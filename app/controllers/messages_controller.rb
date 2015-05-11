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
    #@inner = params[:inner].name
    @message = Message.new(message_params)
    #@message = @inner.name
    respond_to do |format|
      if @message.save
        format.json { render json: @success = '{"status":"1"}'}
      else
        format.json { render json: @success = '{"status":"2"}'}
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
    @messages = Message.where(recipientname: params[:id]).each
    respond_to do |format|
      format.json { render :index}
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
