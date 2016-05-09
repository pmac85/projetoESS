class RealTeam < ActiveRecord::Base
  validates :name,       presence: true
  validates :image_path, presence: true
end
