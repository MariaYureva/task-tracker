class Tag < ApplicationRecord
  has_many :task_tags, dependent: :destroy
  has_many :tasks, through: :task_tags

  validates :name, presence: true,
            uniqueness: { case_sensitive: false }

  before_update  :forbid_system_mutation
  before_destroy :forbid_system_mutation

  scope :system_tags, -> { where(system: true) }
  scope :custom,      -> { where(system: false) }

  def system?
    self[:system]
  end

  private

  def forbid_system_mutation
    return unless self[:system]

    errors.add(:base, "System tags cannot be modified or deleted")
    throw :abort
  end
end