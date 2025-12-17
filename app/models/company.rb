class Company < ApplicationRecord
  has_many :profiles, dependent: :destroy
  has_many :users, through: :profiles
  has_many :meetings, dependent: :destroy
  has_many :evaluation_criteria, dependent: :destroy

  validates :name, presence: true
end
