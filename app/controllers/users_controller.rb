class UsersController < ApplicationController
  before_action :set_user, only: [:show, :pubkey]
  skip_before_filter :verify_authenticity_token

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # Get /users/1/pubkey
  def pubkey
    respond_to do |format|
      format.json { render :pubkey, location: @user }
    end
  end

  # POST /users
  # POST /users.json
  def create
    begin
    @user = User.new(user_params)
    if User.find_by_name(params[:name]) != nil
      respond_to do |format|
          format.json { render json: '{"status":"3"}'}
      end
    else
      respond_to do |format|
        if @user.save
          format.json { render json: '{"status":"1"}'}
        else
          format.json { render json: '{"status":"2"}'}
        end
      end
    end
    rescue Exception
      render json: '{"status":"2"}'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      if User.find_by_name(params[:id]) != nil then
      @user = User.find_by_name(params[:id])
      else
        respond_to do |format|
          format.json { render json: @success = '{"status":"3"}'} #and return
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :public_key, :private_key_enc, :salt_master_key)
    end
end
