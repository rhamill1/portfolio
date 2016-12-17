class Project < ApplicationRecord
  extend FriendlyId
  friendly_id :project_name, use: :slugged
end
