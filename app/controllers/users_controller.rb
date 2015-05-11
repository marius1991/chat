class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :pubkey]
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

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
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
    @user = User.new(user_params)
    if User.find_by_name(params[:name]) != nil
      respond_to do |format|
          format.json { render json: @success = '{"status":"2"}'}
      end
    else
      respond_to do |format|
        if @user.save
          format.json { render json: @success = '{"status":"1"}'}
        else
          format.json { render json: @success = '{"status":"2"}'}
        end
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.json { render :show, status: :ok, location: @user }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by_name(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :public_key, :private_key, :salt_master_key)
    end
end
