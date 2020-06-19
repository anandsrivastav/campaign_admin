class Job < ApplicationRecord
  self.table_name = "delayed_jobs"
  belongs_to :campaign
end
