class Route < ApplicationRecord
  enum http_method: [:GET, :POST, :PUT, :PATCH, :DELETE]

  has_many :request_headers, inverse_of: :http_message, as: :http_message, class_name: 'Header', dependent: :destroy
  has_many :request_query_parameters, inverse_of: :route, class_name: 'QueryParameter', dependent: :destroy
  has_many :responses, inverse_of: :route, dependent: :destroy
  has_many :resource_representations, through: :responses
  has_many :reports
  has_many :mocks, through: :responses

  belongs_to :resource, inverse_of: :routes
  belongs_to :request_resource_representation, class_name: "ResourceRepresentation"
  belongs_to :active_mock, class_name: 'MockInstance', foreign_key: 'mock_instance_id'

  accepts_nested_attributes_for :request_headers, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :request_query_parameters, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true, uniqueness: { scope: :resource }
  validates :http_method, presence: true
  validates :url, presence: true
  validates :resource, presence: true, uniqueness: { scope: [:http_method, :url]}

  scope :of_project, ->(project) { joins(:resource).where(resources: { project_id: project.id }) }

  audited
  has_associated_audits


  def request_json_instance
    GenerateJsonInstanceService.new(request_json_schema).execute if request_json_schema
  end

  def request_json_schema
    ResourceRepresentationSchemaSerializer.new(
      request_resource_representation,
      is_collection: request_is_collection,
      root_key: request_root_key
    ).as_json if request_resource_representation
  end
end
