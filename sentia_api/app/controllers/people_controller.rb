class PeopleController < ApplicationController
  def index
    @people = Person.includes(:locations, :affiliations)
    
    if params[:search].present?
      query = "%#{params[:search]}%".downcase
      @people = @people.where("LOWER(first_name) ILIKE :search OR LOWER(last_name) ILIKE :search", search: query)
    end

    sort_column = params.fetch(:sort, 'first_name')
    sort_direction = params.fetch(:direction, 'asc')
    @people = @people.order("#{sort_column} #{sort_direction}")
    
    people_total = @people.count
    page = params.fetch(:page, 1)
    per_page = params.fetch(:per_page, 10)
    @people = @people.page(page).per(per_page)

    render json: {
      total_count: people_total,
      page: page,
      per_page: per_page,
      data: @people
    }, status: :ok 
  end

  def import
    importer = CsvImporter.import!

    render json: { message: "CSV successfully imported." }, status: :ok
  rescue => e
    render json: { error: "Import failed: #{e.message}" }, status: :unprocessable_entity
  end
end
