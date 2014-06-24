require 'elasticsearch'
require 'tasklist_representer'
require 'user_representer'
require 'mathn'

class Es < OpenStruct
    INDEX      = 'tw_testing'
    TASKLIST   = 'tasklist'
    MEMBERLIST = 'memberlist'
    DUMMYUSER  = 537



    def initialize
        @client = Elasticsearch::Client.new url: 'http://172.18.1.21:9200'
        @client.transport.reload_connections!
        @client.cluster.health
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
                                field: "taskStatus.raw"
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
                                    field: "isFinishedOnTime"
                                  }
                                }
                              ]
                            }
                          },
                          aggs: {
                            OnTime: {
                              filter: {
                                bool: {
                                  must: [
                                    {
                                      term: {
                                        isFinishedOnTime: "true"
                                      }
                                    }
                                  ]
                                }
                              }
                            },
                            OverDue: {
                              filter: {
                                bool: {
                                  must: [
                                    {
                                      term: {
                                        isFinishedOnTime: "false"
                                      }
                                    }
                                  ]
                                }
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
                                      from: 1,
                                      to: 5
                                    }
                                  }
                                }
                              ]
                            }
                          },
                          aggs: {
                            StarRate: {
                              avg: {
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
        else
            response = @client.search index: Es::INDEX, type: Es::TASKLIST, body: {
                size: 1,
                aggs: {
                    Assignee: {
                        terms: {
                            field: "assigneeId",
                            size: 1
                        },
                        aggs: {
                            Month2Date: {
                                filter: {
                                    bool: {
                                        must: [{
                                            exists: {
                                                field: "completedDate"
                                            }
                                        }, {
                                            range: {
                                                completedDate: {
                                                    from: "2014-06-01T00:00+0700"
                                                }
                                            }
                                        }]
                                    }
                                },
                                aggs: {
                                    HavingScore: {
                                        filter: {
                                            bool: {
                                                must_not: [{
                                                    term: {
                                                        satisfiedScore: 0
                                                    }
                                                }]
                                            }
                                        },
                                        aggs: {
                                            Star: {
                                                avg: {
                                                    field: "satisfiedScore"
                                                }
                                            }
                                        }
                                    },
                                    HavingDueDate: {
                                        filter: {
                                            bool: {
                                                must: [{
                                                    exists: {
                                                        field: "estimatedDueDate"
                                                    }
                                                }]
                                            }
                                        },
                                        aggs: {
                                            OnTime: {
                                                terms: {
                                                    field: "isFinishedOnTime",
                                                    size: 0
                                                }
                                            }
                                        }
                                    },
                                    NoDueDate: {
                                        filter: {
                                            bool: {
                                                must: [{
                                                    missing: {
                                                        field: "estimatedDueDate"
                                                    }
                                                }]
                                            }
                                        },
                                        aggs: {
                                            Count: {
                                                value_count: {
                                                    field: "estimatedDueDate"
                                                }
                                            }
                                        }
                                    },
                                    TaskStatus: {
                                        terms: {
                                            field: "taskStatus",
                                            size: 0
                                        }
                                    }
                                }
                            }
                            # ComingTasksDue: {
                            #     filter: {
                            #         bool: {
                            #             must: [{
                            #                 exists: {
                            #                     field: "estimatedDueDate"
                            #                 }
                            #             }]
                            #         }
                            #     },
                            #     aggs: {
                            #         Range: {
                            #             date_range: {
                            #                 field: "estimatedDueDate",
                            #                 format: "date_time",
                            #                 ranges: [{
                            #                     from: "2014-06-01T00:00+0700",
                            #                     to: "2014-06-01T00:00+0700||+1d-1s"
                            #                 }, {
                            #                     from: "2014-06-01T00:00+0700||+2d",
                            #                     to: "2014-06-01T00:00+0700||+2d-1s"
                            #                 }]
                            #             }
                            #         }
                            #     }
                            # }
                        }
                    }
                },
                sort: [{
                    estimatedDueDate: {
                        order: "asc"
                    }
                }]
            }
        end
        result   = Hashie::Mash.new response
        data = {}
        result.aggregations.Assignee.buckets.each do |bucket|
            # Mont-to-Date
            data[:archievement]   = bucket.Month2Date
            data[:overDue]        = data[:archievement].HavingDueDate.OverDue.doc_count.blank? ? 0 : data[:archievement].HavingDueDate.OverDue.doc_count
            data[:onTime]         = data[:archievement].HavingDueDate.OnTime.doc_count.blank? ? 0 : data[:archievement].HavingDueDate.OnTime.doc_count
            data[:noTargetDate]   = data[:archievement].NoTargetDate.doc_count.blank? ? 0 : data[:archievement].NoTargetDate.doc_count
            data[:closedTask]     = data[:onTime]+data[:overDue]+data[:noTargetDate]
            data[:startRate]      = data[:archievement].HavingScore.StarRate.value.blank? ? 0 : data[:archievement].HavingScore.StarRate.value
            data[:onTimeCompletion] = data[:closedTask].zero? ? 0 : (data[:onTime]/data[:closedTask])*100

            # @schedule     = bucket.ComingTasksDue.Range
        end
        return Hashie::Mash.new data
    end
end