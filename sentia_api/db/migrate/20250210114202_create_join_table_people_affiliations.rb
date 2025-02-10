class CreateJoinTablePeopleAffiliations < ActiveRecord::Migration[7.0]
  def change
    create_join_table :people, :affiliations do |t|
      t.index [:person_id, :affiliation_id]
    end
  end
end
