class CategoriesController < ApplicationController
  before_filter :login_required
  
  def index
    @level1_categories = Category.roots
  end
  
  def new
    @category = Category.new
  end
  
  def create
    @category = Category.new(params[:category])

    if params[:parent_id].blank?
      @category.save
    else
      @category.save_as_child_of(Category.find(params[:parent_id]))
    end
    redirect_to "/categories"
  end
end
