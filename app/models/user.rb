class User < ApplicationRecord
  belongs_to :residency_location
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  STATUSES = ['R2', 'R3', 'Other']
end
