# -*- coding: utf-8 -*-
class CoursesController < ApplicationController
  before_filter :login_required
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
    @next_course_teachers = current_user.get_next_course_teachers
  end

  def next_for_teacher
    @next_course_teachers = current_user.get_next_course_teachers
  end

end
