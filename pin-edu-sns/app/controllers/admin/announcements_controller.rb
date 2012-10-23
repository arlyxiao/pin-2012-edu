class Admin::AnnouncementsController < ApplicationController
  layout 'admin'
  before_filter :login_required
  
  def new
    @announcement = current_user.created_announcements.build
  end

  def index
    @announcements = Announcement.paginated(params[:page])
  end

  def create
    @announcement = current_user.created_announcements.build params[:announcement]
    return redirect_to [:admin, @announcement] if @announcement.save
    render :action => :new
  end

  def show
    @announcement = Announcement.find(params[:id])
  end

  def destroy
    Announcement.find(params[:id]).destroy
    redirect_to :back
  end

end