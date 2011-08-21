class Track < ActiveRecord::Base
	belongs_to :album, :foreign_key => 'album'
	belongs_to :genre, :foreign_key => 'genre'
	belongs_to :band, :foreign_key => 'band'
	belongs_to :year, :foreign_key => 'year'
	has_many :pic
end

class Album < ActiveRecord::Base
	has_many :track
end

class Genre < ActiveRecord::Base
	has_many :track
end

class Year < ActiveRecord::Base
	has_many :track
end

class Band < ActiveRecord::Base
	has_many :track
end

class Pic < ActiveRecord::Base
	belongs_to :track
end
