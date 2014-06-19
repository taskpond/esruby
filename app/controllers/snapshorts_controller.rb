# require 'hash'
require 'user_representer'

class SnapshortsController < ApplicationController
    before_filter :fetch_data, only: [:daily]
    before_filter :fetch_user, only: [:index]

    def index
        @users = Hashie::Mash.new User.new(@users).extend(UserRepresenter).to_hash
    end

    def show
    end

    def daily
        render layout: false

        @archievement = {}
        @schedule     = {}
        @assign_to_me = {}
        @assign_by_me = {}
        @my_todo      = {}
    end

    private
        def connect
            @client = Elasticsearch::Client.new url: 'http://172.18.1.21:9200', log: true
            @client.transport.reload_connections!
            @client.cluster.health
        end

        def fetch_user
            connect
            index    = params[:index].present? && !params[:index].blank? ? params[:index] : 'tw_testing'
            type     = params[:type].present? && !params[:type].blank? ? params[:type] : 'memberlist'
            response = @client.search index: index, type: type, body: { size: 10 }
            @users   = Hashie::Mash.new response
        end

        def fetch_data
            connect

            index  = params[:index].present? && !params[:index].blank? ? params[:index] : 'tw_testing'
            type   = params[:type].present? && !params[:type].blank? ? params[:type] : 'tasklist'


            if params[:id].present? && !params[:id].blank?
                response = @client.search index: index, type: type, id: params[:id], body: {
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
            else
                response = @client.search index: index, type: type, body: {
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
            @result   = Hashie::Mash.new response
        end
end