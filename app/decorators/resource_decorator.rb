class ResourceDecorator < Draper::Decorator
  delegate_all

  def resource_attributes_by_name
    # Note: Clément Villain 29/12/17
    # We do the sorting in ruby and not with active record
    # because we want to keep non persited objects
    object.resource_attributes.sort_by(&:name)
  end
end