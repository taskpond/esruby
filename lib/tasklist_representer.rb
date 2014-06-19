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

    property :aggregations do
        property :Assignee do
            collection :buckets do
                property :key, as: :userId
                property :doc_count
                property :Month2Date do
                    property :doc_count
                    property :HavingDueDate do
                        property :doc_count
                        property :OnTime do
                            collection :buckets
                        end
                    end
                end
                property :ComingTasksDue do
                    property :doc_count
                    property :Range do
                        collection :buckets
                    end
                end
            end
        end
    end
end