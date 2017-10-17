module AttributesHelper
  def format_type(primitive_type, resource_id, is_array)
    base_type = primitive_type.nil? ? Resource.find(resource_id).name : primitive_type
    is_array ? "array<#{base_type}>" : base_type
  end
end