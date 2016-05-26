class League < ActiveRecord::Base
  has_many :teams
  has_many :journeys
  validates :name, presence:  true
  validates :initial_date, presence: true
  validate :date_cannot_be_in_the_past

  def date_cannot_be_in_the_past
    if initial_date.present? && initial_date < Date.today
      errors.add(:initial_date, "Date can't be in the past")
    end
  end
end
