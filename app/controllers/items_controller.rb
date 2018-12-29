class ItemsController < ApplicationController
  before_action :merchant_or_admin?
  skip_before_action :merchant_or_admin, only: [:index, :show]

  def index
    @items = Item.all
  end

  def show
    @item = Item.find(params[:id])
    @average_fulfillment_time = @item.average_fulfillment_time
  end

  def new
    @item = Item.new
  end

  def create
    render_404 unless current_merchant?

    thumbnail = params[:item][:thumbnail]
    File.open(Rails.root.join('app', 'assets', 'images', thumbnail.original_filename), 'wb') do |file|
      file.write(thumbnail.read)
    end

    current_user.items.create(item_params)
    redirect_to dashboard_items_path
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])

    update_item(@item, params[:item])
    flash[:success] = "You successfully edited that item!"
    redirect_to dashboard_items_path if current_merchant?
    redirect_to items_path if current_admin?
  end

  def destroy
    item = Item.find(params[:id])
    item.destroy
    redirect_to dashboard_items_path if current_merchant?
    redirect_to items_path if current_admin?
  end

  def toggle_item
    item = Item.find(params[:id])
    item.toggle_enabled
    redirect_to dashboard_items_path
  end

  private

  def item_params
    thing = params[:item][:thumbnail].original_filename
    params[:item][:thumbnail] = thing
    params.require(:item).permit(:name, :description, :price, :thumbnail, :inventory)
  end

  def update_item(item, params)
    params.each do |attribute, value|
      next if value.blank? || item[attribute] == value
      item[attribute] = value
    end
    item.save
  end

  def merchant_or_admin?
    render_404 unless current_admin? || current_merchant?
  end
end
