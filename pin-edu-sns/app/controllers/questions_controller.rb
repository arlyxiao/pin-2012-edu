# -*- coding: utf-8 -*-
class QuestionsController < ApplicationController
  before_filter :login_required
  before_filter :pre_load

  def pre_load
    @question  = Question.find params[:id] if params[:id]
  end

  def index
    type = params[:type]

    if current_user.is_student?
      case type
      when 'answered'
        @questions = current_user.questions.answered
      when 'unanswered'
        @questions = current_user.questions.unanswered
      else
        @questions = current_user.questions
      end
    else
      case type
      when 'answered'
        @questions = Question.with_teacher(current_user).answered
      when 'unanswered'
        @questions = Question.with_teacher(current_user).unanswered
      else
        @questions = Question.with_teacher(current_user)
      end
    end

  
    @questions = @questions.paginate(:page => params[:page]).order('id DESC')
  end


  def new
  end

  def create
    @question = current_user.questions.build(params[:question])
    if @question.save
      return redirect_to "/questions"
    end
    
    error = @question.errors.first
    flash[:error] = error[1]

    redirect_to "/questions/new"
  end


  def update
    if @question.update_attributes(params[:question])
      return redirect_to :back
    end

    error = @question.errors.first
    flash[:error] = error[1]
    redirect_to "/questions/#{@question.id}/edit"
  end


  def show
  end
  

  def destroy
    if current_user == @question.creator || current_user == @question.teacher_user
      @question.remove
    end
    render :text => 'ok'
  end

end
