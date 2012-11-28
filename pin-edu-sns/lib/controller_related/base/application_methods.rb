module ApplicationMethods
  def self.included(base)
    # 拦截ie6的访问
    base.before_filter :hold_ie678
    # 修正IE浏览器请求头问题
    base.before_filter :fix_ie_accept
    # 对错误显示友好的页面
    base.around_filter :catch_some_exception
  end

  #-----------------------
  def render_status_page(code, exception, message)
    p exception.message
    puts exception.backtrace*"\n"

    case code
    when 404
      render "layouts/status_page/404_page", :status=>404, :layout => false,
        :locals=>{:exception=>exception,:message=>message}
    when 500
      render "layouts/status_page/500_page", :status=>500, :layout => false,
        :locals=>{:exception=>exception,:message=>message}
    end
  end
  #----------------------

  def hold_ie678
    return if params[:controller] == 'file_entities' && params[:action] == 'download'
    
    if /MSIE 6/.match(request.user_agent)
      render "layouts/status_page/hold_ie678",:layout=>false
    end

    if /MSIE 7/.match(request.user_agent)
      render "layouts/status_page/hold_ie678",:layout=>false
    end

    if /MSIE 8/.match(request.user_agent)
      render "layouts/status_page/hold_ie678",:layout=>false
    end
  end

  def catch_some_exception
    yield
  rescue ActiveRecord::RecordNotFound=>ex
    render_status_page(404,ex,'正在访问的页面不存在，或者已被删除。')
  rescue Redis::CannotConnectError=>ex
    render_status_page(500,ex,'redis 服务出现了错误')
  rescue Riddle::ConnectionError=>ex
    render_status_page(500,ex,'sphinx 服务出现了错误')
  rescue Exception=>ex
    render_status_page(500,ex,'未知错误')
  end

  def fix_ie_accept
    if /MSIE/.match(request.user_agent) && request.env["HTTP_ACCEPT"]!='*/*'
      if !/.*\.gif/.match(request.url)
        request.env["HTTP_ACCEPT"] = '*/*'
      end
    end
  end

  def is_android_client?
    request.headers["User-Agent"] == "android"
  end

end
