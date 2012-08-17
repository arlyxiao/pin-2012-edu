# encoding: utf-8
class HomeworksController < ApplicationController
  before_filter :pre_load_teacher, :except => [:show, :index, :create_student_upload, :download_teacher_zip, :set_submitted, :student]
  before_filter :login_required

  def pre_load_teacher
    return redirect_to '/' unless current_user.is_teacher?
  end
  
  def create
    @homework = current_user.teacher_homeworks.build(params[:homework])
    if @homework.save
      @homework.share_to_expression({:teams => params[:teams]}.to_json)
      
      if params[:teacher_attachment_ids]
        params[:teacher_attachment_ids].each do |id|
          attach = HomeworkTeacherAttachment.find(id)
          attach.homework = @homework
          attach.save
        end
      end

      return redirect_to @homework
    end
    
    error = @homework.errors.first
    flash.now[:error] = "#{error[0]} #{error[1]}"
    redirect_to '/homeworks/new'
  end
  
  def create_teacher_attachment
    file_entity = FileEntity.find(params[:file_entity_id])
    @homework_teacher_attachment = HomeworkTeacherAttachment.create(:creator => current_user, :name =>params[:file_name], :file_entity => file_entity)
    render :text => @homework_teacher_attachment.id
  end
  
  def create_student_upload
    upload = HomeworkStudentUpload.find_or_initialize_by_creator_id_and_requirement_id(params[:homework_student_upload][:creator_id], params[:homework_student_upload][:requirement_id])
    upload.update_attributes params[:homework_student_upload]
    upload.name = params[:file_name]
    upload.file_entity = upload.file_entity || FileEntity.new
    upload.file_entity.update_attributes :attach => params[:attachment], :merged => true
    upload.save
    render :text => upload.name
  end

  def new
    @homework = Homework.new
    @teacher_attachments = []
    @requirements = []

    @courses = Course.where(:teacher_user_id => current_user.id)
    @teams = Team.where(:teacher_user_id => current_user.id)
  end

  def index
    if params[:status] == 'deadline'
      @homeworks = current_user.deadline_homeworks
      return
    end

    if params[:status] == 'undeadline'
      @homeworks = current_user.undeadline_homeworks
      return
    end

    @homeworks = current_user.homeworks
  end
  
  def show
    @homework = Homework.find(params[:id])
  end

  def edit
    @homework = Homework.find(params[:id])
    @homework_student_upload_requirements = HomeworkRequirement.where(:homework_id => @homework.id)
    @teacher_attachments = HomeworkTeacherAttachment.where(:homework_id => @homework.id)

    @courses = Course.where(:teacher_user_id => current_user.id)
    @teams = Team.where(:teacher_user_id => current_user.id)

    @selected_teams = @homework.homework_assign_rule.expression[:teams].map(&:to_i)
    @requirements = HomeworkRequirement.where(:homework_id => @homework.id)
  end

  def update
    @homework = Homework.find(params[:id])
    @homework.update_attributes(params[:homework])
    if @homework.save
      @homework.share_to_expression({:teams => params[:teams]}.to_json)
      
      if params[:teacher_attachment_ids]
        params[:teacher_attachment_ids].each do |id|
          attach = HomeworkTeacherAttachment.find(id)
          attach.homework = @homework
          attach.save
        end
      end

      return redirect_to @homework
    end
    
    error = @homework.errors.first
    flash.now[:error] = "#{error[0]} #{error[1]}"
    redirect_to '/homeworks/new'
    return redirect_to @homework if @homework.save
    redirect_to :back
  end

  def student
    unless (current_user.is_teacher? || current_user.id == params[:user_id].to_i)
      return redirect_to '/'
    end

    @homework = Homework.find(params[:homework_id])
    @student_user = User.find(params[:user_id])
  end
  
  def download_teacher_zip
    homework = Homework.find(params[:id])
    
    homework.build_teacher_attachments_zip(homework.creator)
    
    send_file "/MINDPIN_MRS_DATA/attachments/homework_attachments/homework_teacher#{homework.creator.id}_#{homework.id}.zip"
  end

  def download_student_zip
    homework = Homework.find(params[:homework_id])
    student = User.find(params[:user_id])
    homework.build_student_uploads_zip(student)
    send_file "/MINDPIN_MRS_DATA/attachments/homework_attachments/homework_student#{student.id}_#{homework.id}.zip"
  end

  def set_finished
    homework = Homework.find(params[:homework_id])
    user = User.find(params[:user_id])

    homework.set_finished_by!(user)
    render :text => 'set finished!'
  end

  def set_submitted
    unless (current_user.is_student? && current_user.id == params[:user_id].to_i)
      return redirect_to '/'
    end

    assign = HomeworkAssign.find_by_homework_id_and_user_id params[:homework_id], params[:user_id]
    assign.homework.set_submitted_by!(current_user, params[:content])
    render :text => 'set submitted!'
  end

  def destroy_teacher_attachment
    HomeworkTeacherAttachment.find(params[:id]).destroy
    render :text => 'attachment destroyed!'
  end

  def destroy_requirement
    HomeworkRequirement.find(params[:id]).destroy
    render :text => 'requirement destroyed!'
  end
end
