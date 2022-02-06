class SourcesController < ApplicationController
  
  def index
  end
  
  def new
    @source = current_user.sources.new
  end
  
  def create
    current_user.sources.create(source_params)
  end
  
  def edit
    @source = Source.find(params[:id])
  end
  
  def update
    @source = Source.find(params[:id])
    @source.update_attributes(source_params)
  end
  
  def destroy
    source = Source.find(params[:id])
    source.destroy
  end
  
  private
  
  def source_params
    params.require(:source).permit(:name)
  end
end
