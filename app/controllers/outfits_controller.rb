class OutfitsController < ApplicationController
  before_action :set_outfits, only: %i[show destroy]
  def index
    @outfits = current_user.outfits
  end

  def show
  end

  def create
    @outfit = current_user.outfits.new(outfit_params)
    if @outfit.save
      redirect_to outfits_path, notice: "Outfit saved!"
    else
      redirect_back fallback_location: root_path, alert: "Could not save your outfit"
    end
  end

  def destroy
    @outfit.destroy
    redirect_to outfits_path, status: :see_other
  end

  private

  def outfit_params
    params.require(:outfit).permit(:name, :season, :image, :details)
  end

  def set_outfits
    @outfit = current_user.outfits.find(params[:id])
  end
end
