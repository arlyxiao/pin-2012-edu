# -*- coding: utf-8 -*-
class CoursesController < ApplicationController
  before_filter :login_required
  before_filter :teacher_only, :only => [:create_score_list, :new_score_list]
  before_filter :per_load

  def per_load
    @course  = Course.find params[:id] if params[:id]
  end


  def index
    @courses = Course.paginated(params[:page])
  end

  def show
    @current_tab = (params[:tab] || :basic).to_sym
  end

  def for_student
    @student_courses = current_user.get_student_course_teachers(:semester => Semester.now)
  end

  def for_teacher
    @teacher_courses = current_user.get_teacher_course_teachers(:semester => Semester.now)
  end

  # 从现在时间开始，本周内上的课程，包括当前正在进行的课程
  def next_for_student
    @next_course_teachers = []
    
    current_cte = CourseTimeExpression.get_by_time(Time.now)

    student_courses = current_user.get_student_course_teachers(:semester => Semester.now)
    student_courses.each do |course_teacher|
      @next_course_teachers += course_teacher.get_next_courses_by_time_expression(current_cte)
    end

    @next_course_teachers = @next_course_teachers.sort_by {|class_detail| class_detail[:weekday]}
    @next_course_teachers = @next_course_teachers.group_by{|item| item[:weekday]}

  end

  def next_for_teacher

    @next_course_teachers = []
    
    current_cte = CourseTimeExpression.get_by_time(Time.now)

    teacher_courses = current_user.get_teacher_course_teachers(:semester => Semester.now)
    teacher_courses.each do |course_teacher|
      @next_course_teachers += course_teacher.get_next_courses_by_time_expression(current_cte)
    end

    @next_course_teachers = @next_course_teachers.sort_by {|class_detail| class_detail[:weekday]}
    @next_course_teachers = @next_course_teachers.group_by{|item| item[:weekday]}
  end


  def score_lists
    @current_semester = Semester.get_by_value params[:semester] if params[:semester]
    @current_course = Course.find params[:course_id] if params[:course_id]

    @courses = current_user.get_teacher_courses :semester => Semester.now
  end

  def new_score_list
    @courses = current_user.get_teacher_courses :semester => Semester.now
  end

  def create_score_list
    semester = Semester.now

    CourseStudentScore.create_list_for :semester     => semester,
                                       :course       => Course.find(params[:course_id]),
                                       :teacher_user => current_user

    redirect_to score_lists_courses_path :semester  => semester.value,
                                         :course_id => params[:course_id]
  end

protected

  def teacher_only
    return redirect_to :back if !current_user.is_teacher?
  end

end
