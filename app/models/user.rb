class User < ApplicationRecord
  belongs_to :residency_location

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  STATUSES = ['R2', 'R3', 'Other']
end
