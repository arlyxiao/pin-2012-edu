class MediaShareRule < ActiveRecord::Base
  after_commit :enqueue_build_share
  after_create :update_achievement

  belongs_to :media_resource

  belongs_to :creator,
             :class_name  => 'User',
             :foreign_key => 'creator_id'

  def build_expression(options = {})
    options[:users] ||= []
    options[:courses] ||= []
    options[:teams] ||= []

    self.expression = options.to_json
  end

  def expression
    exp = read_attribute(:expression)
    exp && JSON.parse(exp, :symbolize_names => true)
  end

  def get_receiver_ids
    direct_ids = expression[:users]

    course_user_ids = expression[:courses].map {|cid|
      Course.find cid
    }.map {|course| [course.teacher, course.students]}.flatten.map(&:user_id)

    team_user_ids = expression[:teams].map {|tid|
      Team.find tid
    }.map {|team| [team.teacher, team.students]}.flatten.map(&:user_id)

    user_ids = (direct_ids + course_user_ids + team_user_ids).flatten.compact.uniq
    user_ids.delete(self.media_resource.creator.id)

    user_ids
  end

  def get_receivers
    User.find get_receiver_ids
  end

  def build_share
    get_receivers.each {|user|
      MediaShare.create :creator        => self.media_resource.creator,
                        :media_resource => self.media_resource,
                        :receiver       => user
    }
  end

  private

  def enqueue_build_share
    BuildMediaShareResqueQueue.enqueue(self.id)
  end

  def update_achievement
    rate = self.creator.share_rate

    achievement = Achievement.find_or_initialize_by_user_id(self.creator.id)
    achievement.share_rate = rate
    achievement.save
    UserShareRateTipMessage.notify_share_rank achievement.creator
  end

  module UserMethods
    def self.included(base)
      base.has_many :media_share_rules,
                    :foreign_key => 'creator_id'

      base.send     :include,
                    InstanceMethods
    end

    module InstanceMethods
      def share_rate
        shared_count = self.media_share_rules.count
        total_count  = self.media_resources.count

        shared_count / total_count.to_f * 100
      end
    end
  end
end