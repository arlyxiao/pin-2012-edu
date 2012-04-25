class HomeworksController < ApplicationController
  before_filter :pre_load_teacher, :except => [:show]

  def pre_load_teacher
    return redirect_to '/' unless current_user.is_teacher?
  end
  
  def create
    @homework = current_user.homeworks.build(params[:homework])
    if @homework.save
      teacher_attachements = params[:teacher_attachements]
      unless teacher_attachements.blank?
        teacher_attachements.each do |attachement_id|
          homework_teacher_attachement = HomeworkTeacherAttachement.find(attachement_id)
          homework_teacher_attachement.homework = @homework
          homework_teacher_attachement.creator = current_user
          homework_teacher_attachement.save
        end
      end
      
      # �Ѽ�ͥ��ҵ������༶���ѧ��
      teams = params[:teams]
      unless teams.blank?
        teams.each do |team_id|
          team = Team.find(team_id)
                   
          team.students.each do |student|
            
            # ���ѧ��û�б����䵽��ҵ
            unless @homework.has_assigned(student)
              HomeworkAssign.create(:student => student, :homework => @homework) 
            end
            
          end
        end
      end
      
      return redirect_to @homework
    end
    
    error = @homework.errors.first
    flash.now[:error] = "#{error[0]} #{error[1]}"
    redirect_to '/homeworks/new'
  end
  
  def create_teacher_attachement
    @homework_teacher_attachement = HomeworkTeacherAttachement.create( params[:homework_teacher_attachement] )
    render :text => @homework_teacher_attachement.id
  end
  

  def new
    @homework = Homework.new
    @homework_student_upload_requirement = HomeworkStudentUploadRequirement.new
    
    # ���пγ�
    @courses = Course.all
    
    # �༶�б�
    @teams = Team.all
    
    # ѧ���б�
    @students = Student.all
  end

  def index
    if params[:status] == 'deadline'
      @homeworks = current_user.deadline_teacher_homeworks
    elsif params[:status] == 'undeadline'
      @homeworks = current_user.undeadline_teacher_homeworks
    else
      @homeworks = current_user.homeworks
    end
  end
  
  
  def show
    @homework = Homework.find(params[:id])
  end
  
  
  # ��ʦ�鿴����ĳһѧ����ҵҳ��
  def student
    @homework = Homework.find(params[:id])
    @student = User.find(params[:user_id])
  end
  
  def download_teacher_zip
    homework = Homework.find(params[:id])
    
    # ������ʦ�ϴ��ĸ���ѹ����
    homework.build_teacher_attachements_zip(homework.creator)
    
    render :file => "/web/2012/homework_teacher_attachements/homework_teacher#{homework.creator.id}_#{homework.id}.zip", :content_type => 'application/zip', :status => :ok
  end

end
