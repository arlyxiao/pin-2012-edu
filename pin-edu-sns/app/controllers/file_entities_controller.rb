class FileEntitiesController < ApplicationController
  before_filter :login_required,:only=>[:upload]

  def upload
    file_entity_id = params[:file_entity_id]
    file_name = params[:name]
    file_size = params[:size]
    blob = params[:blob]

    if file_entity_id.blank?
      file_entity = FileEntity.create_by_params(file_name,file_size)
      file_entity.save_first_blob(blob)
    else
      file_entity = FileEntity.find(file_entity_id)
      file_entity.save_new_blob(blob)
    end

    return render :json => {
      :file_entity_id => file_entity.id,
      :saved_size => file_entity.saved_size
    }
  end

  def download
    item = FileEntityDownloadItem.new(params[:download_id])
    file_entity = FileEntity.find(item.file_entity_id)
    redirect_to file_entity.oss_url
  end

  def re_encode
    file_entity = FileEntity.find(params[:id])
    file_entity.into_video_encode_queue
    render :partial => 'aj/file_entity_preview', :locals => {:file_entity => file_entity}
  end
end