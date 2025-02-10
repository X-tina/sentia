class Person < ApplicationRecord
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :affiliations

  enum gender: {'male' => 0, 'female' => 1, 'other' => 2}
  enum species: {
    'human' => 0,
    'wookie' => 2, 
    'unknown' => 3,
    'hutt' => 4,
    'gungan' => 5, 
    'astromech' => 6,
    'droid' => 7,
    'protocol' => 8
  }

  GENDER_MAPPINGS = {
    "male" => 'male',
    "m" => 'male', 
    "female" => 'female',
    "f" => 'female',
    "other" => 'other'
  }

  validates :first_name, presence: true
  validates :last_name, presence: true
end
