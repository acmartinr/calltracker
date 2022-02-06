class VerticalsController < ApplicationController
  
  def index
  end
  
  def new
    @vertical = current_user.verticals.new
  end
  
  def create
    current_user.verticals.create(vertical_params)
  end
  
  def edit
    @vertical = Vertical.find(params[:id])
  end
  
  def update
    @vertical = Vertical.find(params[:id])
    @vertical.update_attributes(vertical_params)
  end
  
  def destroy
    vertical = Vertical.find(params[:id])
    vertical.destroy
  end
  
  private
  
  def vertical_params
    params.require(:vertical).permit(:name)
  end
end
