class OutfitsController < ApplicationController
  before_action :set_outfit, only: %i[show destroy]
  before_action :authenticate_user!
  def index
    @outfits = current_user.outfits
  end

  def show
  end

  def new
    @outfit = current_user.outfits.new
  end

  def create
    @outfit = current_user.outfits.new(outfit_params)
    if @outfit.save
      image = RubyLLM.paint(
        "Edit the picture of this person with this dress code: #{@outfit.details}",
        model: "gpt-image-2",
        with: current_user.profile_picture
      )
      @outfit.photo.attach(
        io: StringIO.new(image.to_blob),
        filename: "outfit.png",
        content_type: image.mime_type
      )
      redirect_to outfits_path, notice: "Outfit saved!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @outfit = current_user.outfits.find(params[:id])
  end

  def update
    @outfit = current_user.outfits.find(params[:id])
    if @outfit.update(outfit_params)
      redirect_to outfit_path(@outfit), notice: "Outfit updated successfully!"
    else
      render :edit, status: :unprocessable_entity
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

  def set_outfit
    @outfit = current_user.outfits.find(params[:id])
  end
end
