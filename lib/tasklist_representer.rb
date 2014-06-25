require 'representable/json'

module TasklistRepresenter
    include Representable::JSON

    # self.representation_wrap= :users

    property :took, as: :takeTime
    # property :hits do
    #     property :total, as: :rows
    #     collection :hits do
    #         # property :_id, as: :userId
    #         property :_source do
    #             property :id, as: :userId
    #             property :assignerId
    #             property :assigneerFirstName
    #             property :assignerLastName
    #             property :assignerFullName
    #             property :assignerAvatarPath
    #             property :assigneeId
    #             property :assigneeFirstName
    #             property :assigneeFullName
    #             property :requestorId
    #             property :subject
    #             property :commentCount
    #             property :completedDate
    #             property :projectId
    #             property :projectName
    #             property :isFinishedOnTime
    #             property :satisfiedScore
    #             property :timestamp
    #             property :updatedDate
    #             property :taskStatus
    #             property :subTaskCount
    #             property :isSubTask
    #             property :hasBeenDeleted
    #             property :hasPendingAssignee
    #             property :relationStatus
    #         end
    #     end
    # end

    property :aggregations do
        property :Assignee do
            collection :buckets do
                property :doc_count
                property :Month2Date do
                    property :doc_count
                    property :HavingDueDate do
                        property :doc_count
                        property :IsFinishOnTime do
                            collection :buckets do
                                property :doc_count
                            end
                        end
                    end
                    property :NoTargetDate do
                        property :doc_count
                    end
                    property :TaskStatus do
                        property :doc_count
                        collection :Closed do
                            property :doc_count
                        end
                    end
                    property :HavingScore do
                        property :doc_count
                        property :Stats do
                            property :count
                            property :min
                            property :max
                            property :avg
                            property :sum
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