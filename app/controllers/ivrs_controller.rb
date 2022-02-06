class IvrsController < ApplicationController
	
	def index
	end
	
  def new
    @ivr = current_user.ivrs.new
  end
end
