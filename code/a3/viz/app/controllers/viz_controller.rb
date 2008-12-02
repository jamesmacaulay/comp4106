class VizController < ApplicationController
  def index
    if request.post?
      @plant = Plant.new(:max_core_heating => params[:N].to_f, :max_volume => params[:X].to_f).start_reactor
    end
  end
end
