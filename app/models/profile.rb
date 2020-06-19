class Profile < ApplicationRecord
  require 'csv'
  validates_presence_of :full_name
  belongs_to :campaign


  def self.to_csv(profiles)
    CSV.generate do |row|
      row << ["full_name", "email", "title", "location", "summary"]
      profiles.each do |profile|
        row << [ profile[:full_name], profile[:email], profile[:title], profile[:location], profile[:summary] ]
      end
    end
  end  

end
