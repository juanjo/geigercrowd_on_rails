class Location < ActiveRecord::Base
  belongs_to :user
  has_many :instruments
  has_many :samples
  validates_presence_of :latitude
  validates_presence_of :longitude
  
  before_save :geocode
  
  def geocode
    if longitude_changed? or latitude_changed?
      Resque.enqueue(Geocode, self.id)
    end
  end
end
