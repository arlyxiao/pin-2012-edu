# -*- coding: utf-8 -*-
class PublicResourcesController < ApplicationController
  # 公共资源列表
  def index
    if params[:category_id].blank?
      @sub_categories = Category.roots
      @public_resources = PublicResource.no_category
      @navigation_categories = []
    else
      @category = Category.find(params[:category_id])
      @sub_categories = @category.children
      @public_resources = PublicResource.of_category(@category)
      @navigation_categories = @category.self_and_ancestors
      @parent_category = @category.parent
    end
    @items = @sub_categories + @public_resources
  end

  # 分享到公共资源
  # for ajax
  def share
    current_resource = MediaResource.find(params[:resource_id])
    category = Category.find_by_id(params[:category_id])
    public_resource_id = current_resource.share_public(category)
    render :text => 'ok'
  end

  def update_tag
    resource = PublicResource.find(params[:id])
    resource.set_tags_by!(current_user, params[:tag_names])
    render :json => resource.tag_list
  end

  # 上传到公共资源 
  def upload
    if params[:file].blank?
      flash_error "先选择一个文件上传"
    else
      PublicResource.upload_by_user(current_user, params[:file])
    end

    redirect_to :back
  end


  
  def index_file
    id = params[:file_entity_id]

    file_entity = FileEntity.find(id)
    return send_file file_entity.attach.path
  end

end
