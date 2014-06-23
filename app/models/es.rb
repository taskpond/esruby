require 'elasticsearch'
require 'tasklist_representer'
require 'user_representer'

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
        @archievement = {}
        @schedule     = {}
        @assign_to_me = {}
        @assign_by_me = {}
        @my_todo      = {}
        @result       = self.fetch_data(user_id)

        @result.aggregations.Assignee.buckets.each do |bucket|
            @archievement = bucket.Month2Date
            @schedule     = bucket.ComingTasksDue.Range
        end

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
            response = @client.search index: Es::INDEX, type: Es::TASKLIST, body: {
                size: 1,
                query: {
                    filtered: {
                        filter: {
                            bool: {
                                should: [
                                    {
                                        term: {
                                            assigneeId: user_id
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
                                        filter: {
                                            bool: {
                                                must: [
                                                    {
                                                        exists: {
                                                            field: "taskStatus"
                                                        }
                                                    }
                                                ]
                                            }
                                        },
                                        aggs: {
                                            Closed: {
                                                filter: {
                                                    bool: {
                                                        must: [
                                                            {
                                                                term: {
                                                                    taskStatus: "close"
                                                                }
                                                            }
                                                        ]
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            },
                            ComingTasksDue: {
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
                                    Range: {
                                        date_range: {
                                            field: "estimatedDueDate",
                                            format: "date_time",
                                            ranges: [{
                                                from: "2014-06-01T00:00+0700",
                                                to: "2014-06-01T00:00+0700||+1d-1s"
                                            }, {
                                                from: "2014-06-01T00:00+0700||+2d",
                                                to: "2014-06-01T00:00+0700||+2d-1s"
                                            }]
                                        }
                                    }
                                }
                            }
                        }
                    }
                },
                sort: [{
                    estimatedDueDate: {
                        order: "asc"
                    }
                }]
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
                            },
                            ComingTasksDue: {
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
                                    Range: {
                                        date_range: {
                                            field: "estimatedDueDate",
                                            format: "date_time",
                                            ranges: [{
                                                from: "2014-06-01T00:00+0700",
                                                to: "2014-06-01T00:00+0700||+1d-1s"
                                            }, {
                                                from: "2014-06-01T00:00+0700||+2d",
                                                to: "2014-06-01T00:00+0700||+2d-1s"
                                            }]
                                        }
                                    }
                                }
                            }
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
        result = Hashie::Mash.new response
        return result
    end
end