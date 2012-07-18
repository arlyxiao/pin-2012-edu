class MediaFile < ActiveRecord::Base

  PLACE_OSS = "oss"
  PLACE_EDU = "edu"
  
  ENCODING = "ENCODING"
  SUCCESS  = "SUCCESS"
  FAILURE  = "FAILURE"
  
  belongs_to :category
  belongs_to :creator, :class_name=>"User", :foreign_key=>"creator_id"

  default_scope order("id DESC")
  
  validates :place, :presence => true, :inclusion => [PLACE_OSS,PLACE_EDU]
  validates :creator,:entry_file_name, :presence => true

  validate  :category_should_be_leafy_or_nil
  def category_should_be_leafy_or_nil
    unless  category.nil? || category.leaf?
      errors.add(:category, "必须保存在叶子分类下或者暂不分类")
    end
  end

  # -----------------------  

  has_attached_file :entry,
    :styles => {
      :large => '460x340#',
      :small => '220x140#'
    },
    :url => lambda { |attachment| attachment.instance._attachment_file_url }

  def _attachment_file_url
    File.join(R::PSUS_ASSET_SITE, "/:class/:attachment/#{self.id}/:style/:basename.:extension")
  end
  
  # ----------------

  def is_video?
    :video == self.content_kind
  end

  def is_audio?
    :audio == self.content_kind
  end

  def is_image?
    :image == self.content_kind
  end
  
  def flv_file_url
    entry.url.gsub(/\?.*/,".flv")
  end
  
  def encode_success?
    SUCCESS == self.video_encode_status
  end

  def file_merge_complete(md5)
    self.file_merged = true
    self.md5 = md5
    self.save
  end

  def file_copy_complete(copy_media_file_id)
    copy_media_file = MediaFile.find(copy_media_file_id)
    self.md5 = copy_media_file.md5
    self.file_merged = true
    self.video_encode_status = copy_media_file.video_encode_status
    self.save
  end
  
  CONTENT_TYPES = {
    :video    => [
        'avi', 'rm',  'rmvb', 'mp4', 
        'ogv', 'm4v', 'flv', 'mpeg',
        '3gp'
      ].map{|x| file_content_type(x)}.uniq - ['application/octet-stream'],
    :audio    => [
        'mp3', 'wma', 'm4a',  'wav', 
        'ogg'
      ].map{|x| file_content_type(x)}.uniq,
    :image    => [
        'jpg', 'jpeg', 'bmp', 'png', 
        'png', 'svg',  'tif', 'gif'
      ].map{|x| file_content_type(x)}.uniq,
    :document => [
        'pdf', 'xls', 'doc', 'ppt'
      ].map{|x| file_content_type(x)}.uniq
  }

  def content_kind
    case self.entry_content_type
    when *CONTENT_TYPES[:video]
      :video
    when *CONTENT_TYPES[:audio]
      :audio
    when *CONTENT_TYPES[:image]
      :image
    when *CONTENT_TYPES[:document]
      :document
    end
  end

  scope :with_kind, lambda {|kind|

    if kind.blank?
      return where('1 = 1')
    end

    if [:video, :audio, :image, :document].include? kind.to_sym
      types = CONTENT_TYPES[kind.to_sym]
      count = types.length
      condition_str = ['?']*count*','

      return where("entry_content_type IN (#{condition_str})", *types)
    end

    if :other == kind.to_sym
      all = CONTENT_TYPES[:video] + 
            CONTENT_TYPES[:audio] + 
            CONTENT_TYPES[:image] + 
            CONTENT_TYPES[:document]

      count = all.length
      condition_str = ['?']*count*','

      return where("entry_content_type NOT IN (#{condition_str})", *all)
    end
  }

  # --- 给其他类扩展的方法
  module UserMethods
    def self.included(base)
      base.has_many :media_files, :foreign_key => :creator_id
    end
  end

  include Comment::CommentableMethods
end