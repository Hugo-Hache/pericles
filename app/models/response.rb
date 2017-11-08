class Response < ApplicationRecord
  belongs_to :route
  belongs_to :resource_representation, inverse_of: :responses

  has_many :headers, inverse_of: :http_message, as: :http_message, dependent: :destroy
  has_many :reports
  has_many :mock_instances

  accepts_nested_attributes_for :headers, allow_destroy: true, reject_if: :all_blank

  validates :status_code, presence: true
  validates :route, presence: true

  audited associated_with: :route

  def errors_from_http_response(http_response)
    errors_for_status(http_response) +
    errors_for_headers(http_response) +
    errors_for_body(http_response)
  end

  def errors_for_status(http_response)
    self.status_code == http_response.status.code ? [] :
    [
      ValidationError.new(
        category: :status_code,
        description: "Status code is #{http_response.status.code} instead of #{self.status_code}"
      )
    ]
  end

  def errors_for_headers(http_response)
    self.headers.map do |h|
       ValidationError.new(
        category: :header,
        description: "#{h.name} is missing from the response headers"
      ) unless http_response.headers.to_h.key? h.name
    end.compact
  end

  def errors_for_body(http_response)
    JSON::Validator.fully_validate(
      json_schema, http_response.body, json: true
    ).map do |error_message|
      ValidationError.new(
        category: :body,
        description: error_message
      )
    end
  end

  def json_instance
    GenerateJsonInstanceService.new(json_schema).execute if json_schema
  end

  def json_schema
    ResourceRepresentationSchemaSerializer.new(
      resource_representation,
      is_collection: is_collection,
      root_key: root_key
    ).as_json if resource_representation
  end
end
