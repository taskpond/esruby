require 'representable/json'

module UserRepresenter
    include Representable::Hash

    # self.representation_wrap= :users

    property :took
    property :hits do
        property :total, as: :rows
        collection :hits do
            # property :_id, as: :userId
            property :_source do
                property :id, as: :userId
                property :firstName
                property :lastName
                property :fullName
                property :email
                property :status
                property :accountStatus
                property :colleagueIds
                property :projectIds
            end
        end
    end
end