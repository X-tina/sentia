class PeopleController < ApplicationController
  def index
    query = Person \
      .left_outer_joins(:locations, :affiliations) \
      .group('people.id, people.first_name, people.last_name, people.gender, people.species, people.weapon, people.vehicle') \
      .select("people.*, string_agg(locations.name, '; ') AS location, string_agg(affiliations.name, '; ') AS affiliation")

    search = params[:search]
    if search.present?
      term = "%#{search.downcase}%"
      query = Person \
        .select("pa.*") \
        .from("(#{query.to_sql}) AS pa") \
        .where(
          "LOWER(first_name) ILIKE :search OR 
          LOWER(last_name) ILIKE :search OR 
          LOWER(location) ILIKE :search OR 
          LOWER(affiliation) ILIKE :search OR 
          weapon ILIKE :search OR
          vehicle ILIKE :search", 
          search: term
        )
    end
 
    sort_column = params.fetch(:sort_key, 'first_name')
    sort_direction = params.fetch(:sort_order, 'asc')

    @people = query.order("#{sort_column} #{sort_direction}")
    
    people_total = @people.to_a.count
    page = params.fetch(:page, 1)
    per_page = params.fetch(:per_page, 10)
    @people = @people.page(page).per(per_page)

    sanitized_attrs = %w[gender species weapon vehicle]
    data = @people.map do |person|
      person.attributes.slice(*sanitized_attrs)
        .merge(
          name: person.full_name,
          location: person.location,
          affiliation: person.affiliation
        )
    end

    render json: {
      total_count: people_total,
      page: page,
      per_page: per_page,
      data: data
    }, status: :ok 
  end

  def import
    unless params[:file].present?
      return render json: { error: "No file provided." }, status: :unprocessable_entity
    end
  
    file = params[:file]
    file_path = Rails.root.join('tmp', file.original_filename)
  
    File.open(file_path, 'wb') do |f|
      f.write(file.read)
    end

    begin
      importer = CsvImporter.new(file_path).import

      render json: { message: "CSV successfully imported." }, status: :ok
    rescue => e
      render json: { error: "Import failed: #{e.message}" }, status: :unprocessable_entity
    ensure
      File.delete(file_path) if File.exist?(file_path)
    end
  end
end
