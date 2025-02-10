require 'csv'

FILE_NAME = 'coding_test_data.csv'.freeze

class CsvImporter
  attr_reader :file_path

  def initialize(file_path = Rails.root.join('db', 'seeds', FILE_NAME))
    @file_path = file_path
  end

  def self.import!
    new.import
  end

  def import
    raise "Seed file not found: #{file_path}" unless File.exist?(file_path)

    CSV.foreach(file_path, headers: true) do |csv_row|
      row = csv_row.to_h
      full_name = row['Name']
      first_name, last_name = full_name&.split

      next if row['Affiliations'].blank?
      next if first_name.blank? || last_name.blank?

      first_name = "#{first_name}".titleize
      last_name  = "#{last_name}".titleize

      weapon  = "#{row['Weapon']}".titleize
      vehicle = "#{row['Vehicle']}".titleize
      locations = "#{row['Location']}".split(',').map { |loc| loc.strip.titleize }
      affiliations = "#{row['Affiliations']}".split(',').map { |aff| aff.strip.titleize }

      ::Person.transaction do
        gender = row['Gender']&.downcase
        gender_value = ::Person::GENDER_MAPPINGS.fetch(gender, 'other')

        person = Person.create!(
          first_name: first_name,
          last_name: last_name,
          gender: gender_value,
          species: row['Species']&.downcase,
          weapon: weapon,
          vehicle: vehicle
        )

        locations.each do |loc_name|
          location = Location.find_or_create_by!(name: loc_name)
          person.locations << location unless person.locations.include?(location)
        end

        affiliations.each do |aff_name|
          affiliation = Affiliation.find_or_create_by!(name: aff_name)
          person.affiliations << affiliation unless person.affiliations.include?(affiliation)
        end
      end
    end
  end
end
