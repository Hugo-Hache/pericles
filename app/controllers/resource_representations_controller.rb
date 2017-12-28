class ResourceRepresentationsController < AuthenticatedController
  before_action :setup_project_and_resource, except: [:index]
  before_action :setup_resource_representation, except: [:index, :new, :create]

  def show
    render(
      json: @representation,
      serializer: ResourceRepresentationSchemaSerializer,
      adapter: :attributes,
      is_collection: ActiveModel::Type::Boolean.new.cast(params[:is_collection]),
      root_key: params[:root_key]
    )
  end

  def new
    @representation = @resource.resource_representations.build
    build_missing_attributes_resource_representations(@representation)
    render layout: 'generic'
  end

  def edit
    build_missing_attributes_resource_representations(@representation)
    render layout: 'generic'
  end

  def create
    @representation = @resource.resource_representations.build(resource_rep_params)
    if @representation.save
      redirect_to project_resource_path(@project, @resource)
    else
      build_missing_attributes_resource_representations(@representation)
      render 'new', layout: 'generic', status: :unprocessable_entity
    end
  end

  def update
    if @representation.update(resource_rep_params)
      redirect_to project_resource_path(@project, @resource)
    else
      build_missing_attributes_resource_representations(@representation)
      render 'edit', layout: 'generic', status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @representation.destroy
    rescue ActiveRecord::InvalidForeignKey
      flash[:error] = t('activerecord.errors.models.resource_representation.attributes.base.destroy_failed_foreign_key')
    end

    redirect_to project_resource_path(@project, @resource)
  end

  private

  def setup_project_and_resource
    @resource = Resource.find(params[:resource_id])
    @project = @resource.project
  end

  def setup_resource_representation
    @representation = ResourceRepresentation.find(params[:id])
  end

  def build_missing_attributes_resource_representations(resource_representation)
    @all_attributes_resource_representations = @resource.resource_attributes.sorted_by_name.map do |attribute|
      resource_representation.attributes_resource_representations.detect do |arr|
        arr.attribute_id == attribute.id
      end || resource_representation.attributes_resource_representations.build(resource_attribute: attribute, key_name: attribute.default_key_name)
    end
  end

  def resource_rep_params
    params.require(:resource_representation).permit(
      :name,
      :description,
      attributes_resource_representations_attributes: [
        :id,
        :resource_representation_id,
        :key_name,
        :is_required,
        :is_null,
        :attribute_id,
        :_destroy
      ]
    )
  end
end
