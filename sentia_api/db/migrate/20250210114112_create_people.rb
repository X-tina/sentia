class CreatePeople < ActiveRecord::Migration[7.0]
  def change
    create_table :people do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :gender
      t.integer :species, default: 0
      t.string :weapon
      t.string :vehicle

      t.timestamps
    end
  end
end
