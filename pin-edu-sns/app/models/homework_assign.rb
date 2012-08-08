# -*- coding: utf-8 -*-
class HomeworkAssign < ActiveRecord::Base
  # --- 模型关联
  belongs_to :homework, :class_name => 'Homework'
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :student
  
  # --- 校验方法
  validates :creator, :presence => true
  
  # --- 给其他类扩展的方法
  module UserMethods
    def self.included(base)
      base.has_many :homework_assigns, :foreign_key => :creator_id
    end
  end
end
