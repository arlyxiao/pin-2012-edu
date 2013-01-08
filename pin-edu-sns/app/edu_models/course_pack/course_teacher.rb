class CourseTeacher < ActiveRecord::Base
  include CourseChangeRecord::CourseTeacherMethods
  belongs_to :course
  belongs_to :teacher_user,
             :class_name  => 'User',
             :foreign_key => :teacher_user_id

  validates :course_id, :presence => true
  validates :teacher_user_id, :presence => true,
    :uniqueness => {:scope => [:course_id,:semester_value]}

  after_destroy :remove_relative_course_student_assigns
  def remove_relative_course_student_assigns
    course_student_assigns.each do |assign|
      assign.destroy
    end
  end

  def semester=(semester)
    @semester = semester
    self.semester_value = semester.value
  end

  def semester
    @semester || (
      if !self.semester_value.blank?
        Semester.get_by_value(self.semester_value)
      end
    )
  end

  # 格式
  # [
  #   {:weekday => weekday, :number => hour},
  #   {:weekday => weekday, :number => hour}
  # ]
  def time_expression_array
    array = JSON.parse(self.time_expression || "[]")
    array.map do |item|
      [item["number"]].flatten.map do |number|
        {:weekday => item["weekday"].to_i, :number => number}
      end
    end.flatten
  end

  def time_expression_array=(time_expression_array)
    self.time_expression = time_expression_array.to_json
  end

  def course_student_assigns
    CourseStudentAssign.where(
      :course_id => self.course_id,
      :teacher_user_id => self.teacher_user_id,
      :semester_value => self.semester_value
    )
  end

  def student_users
    User.joins('inner join course_student_assigns as csa on csa.student_user_id = users.id').
      where("csa.course_id = #{self.course_id} and csa.teacher_user_id = #{self.teacher_user_id} and csa.semester_value = '#{self.semester_value}'")
  end

  def set_students(users)
    students = self.course.get_students(:semester=>self.semester,:teacher_user=>self.teacher_user)

    remove_users = students - users
    self.course_student_assigns.each do |assign|
      assign.destroy if remove_users.include?(assign.student_user)
    end

    add_users = users - students
    add_users.each do |user|
      user.add_course(
        :semester => self.semester,
        :course => self.course,
        :teacher_user => self.teacher_user
      )
    end
  end

  def self.get_by_params(course, semester, teacher_user)
    self.where(
      :course_id => course.id,
      :semester_value => semester.value,
      :teacher_user_id => teacher_user.id
    ).first
  end

  def self.get_all_by_semester(semester)
    self.where(
      :semester_value => semester.value
    )
  end

  def course_time_expressions
    change_result = change_course_time_expressions
    return change_result if !change_result.blank?

    self.time_expression_array.map do |expression|
      number = expression[:number]
      weekday = expression[:weekday]
      
      cte = CourseTimeExpression.new(weekday, number)
      cte.course_teacher = self

      cte
    end
  end

  module UserMethods
    def self.included(base)
      base.has_many :course_teachers, :foreign_key => :teacher_user_id
    end
  end
end
