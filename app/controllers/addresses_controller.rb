class AddressesController < ApplicationController
  before_action :set_user
  before_action :set_address, only: %i[show edit update destroy]

  def index
    @addresses = @user.addresses
  end

  def show
  end

  def new
    @address = @user.addresses.build
  end

  def edit
  end

  def create
    @address = @user.addresses.build(address_params)

    if @address.save
      redirect_to user_address_path(@user, @address), notice: "Address created successfully.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @address.update(address_params)
      redirect_to user_address_path(@user, @address), notice: "Address updated successfully.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to user_addresses_path(@user), notice: "Address deleted successfully.", status: :see_other
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_address
    @address = @user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:street, :city)
  end
end
