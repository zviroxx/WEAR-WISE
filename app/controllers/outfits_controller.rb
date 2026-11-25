class OutfitsController < ApplicationController
  def index
    @outfits = current_user.outfits
  end

  def show
    @outfit = current_user.outfits.find(params[:id])
  end

  def create
    @outfit = current_user.outfits.new(outfit_params)
    if @outfit.save
      redirect_to outfits_path, notice: "Outfit saved!"
    else
      redirect_back fallback_location: root_path, alert: "Could not save your outfit"
    end
  end

  private
  def outfit_params
    params.require(:outfit).permit(:name, :season, :image, :details)
  end
end
