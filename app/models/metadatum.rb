class Metadatum < ApplicationRecord
  include HasPrimitiveType

  belongs_to :project, required: true

  has_many :metadata_responses, dependent: :destroy
  has_many :responses, through: :metadata_responses
  has_many :metadatum_instances

  validates :name, presence: true, uniqueness: { scope: :project, case_sensitive: true }
  validates :primitive_type, presence: true

  audited

  def json_schema
    if datetime? || date?
      non_nullable = { type: :string, format: primitive_type }
    else
      non_nullable = { type: primitive_type }
    end

    if nullable
      { oneOf: [non_nullable, { type: 'null' }] }
    else
      non_nullable
    end
  end
end
