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

            beginning_today      = from.to_datetime.at_beginning_of_day
            end_of_day           = beginning_today.at_end_of_day

            beginning_tomorrow   = from.to_datetime.tomorrow
            end_of_tomorrow      = beginning_tomorrow.at_end_of_day

            beginning_this_week  = from.to_datetime.at_beginning_of_week
            end_of_week          = beginning_this_week.at_end_of_week

            beginning_next_week  = from.to_datetime.next_week
            end_of_next_week     = beginning_next_week.at_end_of_week

            beginning_this_month = from.to_datetime.at_beginning_of_month
            end_of_this_month    = beginning_this_month.at_end_of_month

            beginning_next_month = from.to_datetime.next_month
            end_of_next_month    = beginning_next_month.at_end_of_month

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
                    },
                    UpcomingTasks: {
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
                        Today: {
                          filter: {
                            bool: {
                              must: [
                                {
                                  range: {
                                    estimatedDueDate: {
                                      from: beginning_today,
                                      to: end_of_day
                                    }
                                  }
                                }
                              ]
                            }
                          }
                        },
                        Tomorrow: {
                          filter: {
                            bool: {
                              must: [
                                {
                                  range: {
                                    estimatedDueDate: {
                                      from: beginning_tomorrow,
                                      to: end_of_tomorrow
                                    }
                                  }
                                }
                              ]
                            }
                          }
                        },
                        ThisWeek: {
                          filter: {
                            bool: {
                              must: [
                                {
                                  range: {
                                    estimatedDueDate: {
                                      from: beginning_this_week,
                                      to: end_of_week
                                    }
                                  }
                                }
                              ]
                            }
                          }
                        },
                        NextWeek: {
                          filter: {
                            bool: {
                              must: [
                                {
                                  range: {
                                    estimatedDueDate: {
                                      from: beginning_next_week,
                                      to: end_of_next_week
                                    }
                                  }
                                }
                              ]
                            }
                          }
                        },
                        ThisMonth: {
                          filter: {
                            bool: {
                              must: [
                                {
                                  range: {
                                    estimatedDueDate: {
                                      from: beginning_this_month,
                                      to: end_of_this_month
                                    }
                                  }
                                }
                              ]
                            }
                          }
                        },
                        NextMonth: {
                          filter: {
                            bool: {
                              must: [
                                {
                                  range: {
                                    estimatedDueDate: {
                                      from: beginning_next_month,
                                      to: end_of_next_month
                                    }
                                  }
                                }
                              ]
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

                # Upcoming Tasks
                data[:upcomingTasks] = bucket.UpcomingTasks
                data[:Today]         = data[:upcomingTasks].Today.doc_count
                data[:Tomorrow]      = data[:upcomingTasks].Tomorrow.doc_count
                data[:ThisWeek]      = data[:upcomingTasks].ThisWeek.doc_count
                data[:NextWeek]      = data[:upcomingTasks].NextWeek.doc_count
                data[:ThisMonth]     = data[:upcomingTasks].ThisMonth.doc_count
                data[:NextMonth]     = data[:upcomingTasks].NextMonth.doc_count
            end

            return Hashie::Mash.new data
        end
    end
end