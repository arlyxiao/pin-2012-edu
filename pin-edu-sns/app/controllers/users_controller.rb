class UsersController < ApplicationController
  def show
    @user = User.find_by_id(params[:id])
    
    # @statuses = Status.all

#    # 用户活动
#    @week_activities_data = @user.the_week_activities_data
#    
#    # 媒体文件
#    @media_files = @user.media_files
#    
#    # 如果是老师，则显示创建的作业列表
#    if @user.is_teacher?
#      @teacher_homeworks = @user.homeworks
#    end
#    
#    # 如果是学生，则显示被分配的作业列表
#    if @user.is_student?
#      @student_homeworks = @user.homework_assigns
#    end
    
  end

end
