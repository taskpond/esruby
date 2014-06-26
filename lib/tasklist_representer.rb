require 'representable/json'

module TasklistRepresenter
    include Representable::JSON

    # self.representation_wrap= :users

    property :took, as: :takeTime
    property :hits do
        property :total
        collection :hits do
            # property :_id, as: :userId
            property :_source, as: :result do
                property :id
                property :assignerId
                property :assignerFirstName
                property :assignerLastName
                property :assignerFullName
                property :assignerAvatarPath
                property :assignerEmail
                property :assigneeId
                property :assigneeFirstName
                property :assigneeLastName
                property :assigneeFullName
                property :assigneeAvatarPath
                property :assigneeEmail
                property :requestorId
                property :subject
                property :commentCount
                property :estimatedDueDate
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
                property :UpcomingTask do
                    property :doc_count
                    property :Today do
                        property :doc_count
                    end
                    property :Tomorrow do
                        property :doc_count
                    end
                    property :ThisWeek do
                        property :doc_count
                    end
                    property :NextWeek do
                        property :doc_count
                    end
                    property :ThisMonth do
                        property :doc_count
                    end
                    property :NextMonth do
                        property :doc_count
                    end
                end
            end
        end
    end
end