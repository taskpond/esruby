require 'elasticsearch'
require 'tasklist_representer'
require 'user_representer'
require 'mathn'

class Es < OpenStruct
    INDEX      = 'tw_master'
    TASKLIST   = 'tasklist'
    MEMBERLIST = 'memberlist'
    DUMMYUSER  = 537

    def initialize
        @client = Elasticsearch::Client.new url: 'http://es.taskworld.com:80', timeout: 1
        # @client.transport.reload_connections!
        # @client.cluster.health
    end

    def daily(user_id)
        user_id ||= Es::DUMMYUSER
        @result = self.fetch_data(user_id)

        SnapshortNotifier.daily_snapshort('user@example.com', 'Daily Snapshort', @result).deliver
    end

    def fetch_user
        response = @client.search index: Es::INDEX, type: Es::MEMBERLIST, body: {
            size: 1,
            aggs: {
                Assignee: {
                    terms: {
                        field: "assigneeId",
                        size: 10
                    }
                }
            }
        }
        return Hashie::Mash.new response
    end

    def fetch_data(user_id)
        if !user_id.blank? && !user_id.to_i.eql?(0)
            from = Time.now.at_beginning_of_month.utc
            to = Time.now.utc

            from = '2014-04-01T00:00:00'
            to = '2014-04-30T00:00:00'
            response = @client.search index: Es::INDEX, type: Es::TASKLIST, body: {
              size: 0,
              query: {
                filtered: {
                  filter: {
                    bool: {
                      must: [
                        {
                          term: {
                            assigneeId: user_id
                          }
                        },
                        {
                          range: {
                            estimatedDueDate: {
                              from: from,
                              to: to
                            }
                          }
                        }
                      ]
                    }
                  }
                }
              },
              aggs: {
                Assignee: {
                  terms: {
                    field: "assigneeId"
                  },
                  aggs: {
                    Month2Date: {
                      filter: {
                        bool: {
                          must: [
                            {
                              exists: {
                                field: "taskStatus"
                              }
                            },
                            {
                              term: {
                                taskStatus: "closed"
                              }
                            }
                          ]
                        }
                      },
                      aggs: {
                        HavingDueDate: {
                          filter: {
                            bool: {
                              must: [
                                {
                                  exists: {
                                    field: "estimatedDueDate"
                                  }
                                }
                              ]
                            }
                          },
                          aggs: {
                            IsFinishOnTime: {
                              terms: {
                                field: "isFinishedOnTime",
                                size: 0
                              }
                            }
                          }
                        },
                        NoTargetDate: {
                          filter: {
                            bool: {
                              must: [
                                {
                                  missing: {
                                    field: "estimatedDueDate"
                                  }
                                }
                              ]
                            }
                          }
                        },
                        HavingScore: {
                          filter: {
                            bool: {
                              must: [
                                {
                                  range: {
                                    satisfiedScore: {
                                      gt: 0
                                    }
                                  }
                                }
                              ]
                            }
                          },
                          aggs: {
                            Stats: {
                              stats: {
                                field: "satisfiedScore"
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }

            result   = Hashie::Mash.new(Snapshort.new(response).extend(TasklistRepresenter).to_hash)
            result   = result.merge(response)

            data = {}
            result.aggregations.Assignee.buckets.each do |bucket|
                # Mont-to-Date
                data[:archievement]   = bucket.Month2Date
                data[:archievement].HavingDueDate.IsFinishOnTime.buckets.each do |item|
                    if item["key"].downcase == 't'
                        data[:overDue] = item.doc_count
                    elsif item["key"].downcase == 'f'
                        data[:onTime] = item.doc_count
                    end
                end
                data[:noTargetDate]   = data[:archievement].NoTargetDate.doc_count.blank? ? 0 : data[:archievement].NoTargetDate.doc_count
                data[:closedTask]     = data[:onTime]+data[:overDue]+data[:noTargetDate]
                data[:startRate]      = data[:archievement].HavingScore.Stats.avg.to_f
                data[:onTimeCompletion] = data[:closedTask].zero? ? 0 : ((data[:onTime]+data[:overDue])/data[:closedTask])*100

                # @schedule     = bucket.ComingTasksDue.Range
            end
            return Hashie::Mash.new data
        end
    end
end