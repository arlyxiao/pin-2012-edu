module MediaResourceHelper

  def media_resource_navs_dirs(current_dir)
    return [] if current_dir.blank?

    dirs = [@current_dir]
    parent_dir = @current_dir.dir
    while !parent_dir.blank? do
      dirs << parent_dir
      parent_dir = parent_dir.dir
    end

    return dirs.reverse
  end

  def media_resource_size_str(media_resource)
    return '' if media_resource.is_dir?

    bytes = media_resource.metadata[:bytes]

    if bytes < 1024
      return "#{bytes} bytes"
    end

    if bytes < 1048576
      s = ((bytes / 1024.0) * 100).round / 100.0
      return "#{s} KB"
    end

    if bytes < 1073741824
      s = ((bytes / 1048576.0) * 100).round / 100.0
      return "#{s} MB"
    end

    s = ((bytes / 1073741824.0) * 100).round / 100.0
    return "#{s} GB"
  end


  def media_resource_cover_src(media_resource)
    if media_resource.is_dir?
      return '/assets/covers/folder.small.png'
    end

    file_entity = media_resource.file_entity
    return 'x' if file_entity.blank?

    case file_entity.content_kind
    when :image
      return File.join('http://', request.host, file_entity.attach.url(:small))
    when :audio
      return '/assets/covers/audio.small.png'
    else "x"
    end
  end

end