class TeachingPlanCourse < ActiveRecord::Base

  validates :course_id, :presence => true
  validates :teaching_plan_id, :presence => true,
    :uniqueness => {:scope => :course_id}

  belongs_to :course
  belongs_to :teaching_plan
end