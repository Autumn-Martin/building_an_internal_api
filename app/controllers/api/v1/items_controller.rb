class Api::V1::ItemsController < ApplicationController

  def index
    render(json: Item.all) # take all items, render to JSON & then render result
  end

  def show
    render json: Item.find(params[:id])
  end
end
