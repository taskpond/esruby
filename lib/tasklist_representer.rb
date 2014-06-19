require 'representable/json'

module TasklistRepresenter
    include Representable::Hash

    # self.representation_wrap= :users

    property :took
    property :hits do
        property :total, as: :rows
        collection :hits do
            # property :_id, as: :userId
            property :_source do
                property :id, as: :userId
                property :assignerId
                property :assigneerFirstName
                property :assignerLastName
                property :assignerFullName
                property :assignerAvatarPath
                property :assigneeId
                property :assigneeFirstName
                property :assigneeFullName
                property :requestorId
                property :subject
                property :commentCount
                property :completedDate
                property :projectId
                property :projectName
                property :isFinishedOnTime
                property :satisfiedScore
                property :timestamp
                property :updatedDate
                property :taskStatus
                property :subTaskCount
                property :isSubTask
                property :hasBeenDeleted
                property :hasPendingAssignee
                property :relationStatus
            end
        end
    end
end