# encoding: utf-8

class MediaResourcesController < ApplicationController
  before_filter :login_required

  def index
    @dir = nil
    @media_resources = current_user.media_resources.root_res.web_order
    render :action => 'index'
  end

  def file
    resource_path = URI.decode(request.fullpath).sub('/file', '')
    current_resource = MediaResource.get(current_user, resource_path)

    if current_resource.is_dir?
      @current_dir = current_resource
      @media_resources = @current_dir.media_resources.web_order
      return render :action => 'index'
    end
    
    if current_resource.is_file?
      return send_file current_resource.attach.path
    end
  end

  def upload_file
    slice_temp_file = SliceTempFile.find(params[:slice_temp_file_id])
    resource_path = URI.decode(request.fullpath).sub('/file_put', '')
    MediaResource.put_slice_temp_file(current_user, resource_path, slice_temp_file)
    render :text=>200
  end

  # for ajax
  def create_folder
    if params[:folder].match(/^([A-Za-z0-9一-龥\-\_\.]+)$/)
      resource_path = File.join(params[:current_path], params[:folder])
      resource = MediaResource.create_folder(current_user, resource_path)

      if resource.blank?
        return render :status => 401,
                      :text => '文件夹创建失败'
      end

      return render :partial => 'media_resources/parts/resources',
                    :locals => {
                      :resources => [resource]
                    }
    end

    render :status => 401,
           :text => '文件夹名不符合规范'

  rescue MediaResource::RepeatedlyCreateFolderError
    render :status => 401,
           :text => '文件夹名重复'
  end

  def destroy
    resource_path = URI.decode(request.fullpath).sub('/file', '')
    MediaResource.get(current_user, resource_path).remove

    render :text => 'ok'
  end

  # 搜索当前登录用户资源
  def search
    @keyword = params[:keyword]
    @media_resources = MediaResource.search(@keyword, 
      :conditions => {:creator_id => current_user.id, :is_removed => 0}, 
      :page => params[:page], :per_page => 20)

  end

  def edit_tag
    resource_path = "/#{params[:path]}"
    @media_resource = MediaResource.get(current_user, resource_path)
  end

  def update_tag
    resource_path = "/#{params[:path]}"
    @media_resource = MediaResource.get(current_user, resource_path)
    @media_resource.tag_list = params[:tag]
    @media_resource.save
    redirect_to File.join('/file',File.dirname(resource_path))
  end

  def file_show
    resource_path = URI.decode(request.fullpath).sub('/file_show', '')
    @media_resource = MediaResource.get(current_user, resource_path)
  end

  def re_encode
    resource_path = "/#{params[:path]}"
    @media_resource = MediaResource.get(current_user, resource_path)
    @media_resource.file_entity.into_video_encode_queue
    render :text=>"200"
  end

end
