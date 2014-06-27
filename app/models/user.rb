class User < ActiveRecord::Base
    include Elasticsearch::Model
end