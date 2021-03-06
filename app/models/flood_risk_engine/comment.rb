module FloodRiskEngine
  class Comment < ActiveRecord::Base
    belongs_to :commentable, polymorphic: true
    belongs_to(:user) if defined?(User)
  end
end
