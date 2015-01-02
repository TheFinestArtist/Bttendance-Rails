class SchoolsUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :school

  # Limit one instance of a (the same) school per user
  validates :school_id, uniqueness: { scope: :user_id }
  validates :identity, presence: true, if: :state_is_student?
  validates :state, presence: true, inclusion: { in: ['supervisor', 'student', 'administrator'] }

  # Set a primary key so we can use standard ActiveRecord methods
  self.primary_key = :user_id

  def state_is_student?
    state == 'student'
  end
end
