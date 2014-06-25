require 'spec_helper'
require 'elasticsearch/extensions/ansi'

describe Es do
  skip "add some examples to (or delete) #{__FILE__}"

  it 'should defined default INDEX' do
    index = 'tw_testing'
    expect(Es::INDEX).to eq index
  end

  it 'should incorrect when INDEX name not same as default variable' do
    index = 'tw_testings'
    expect(index).not_to eq Es::INDEX
  end

  it 'should defined default TYPE' do
    type = 'tasklist'
    expect(Es::TASKLIST).to eq type
  end

  it 'should incorrect when INDEX name not same as default variable' do
    type = 'tasklists'
    expect(type).not_to eq Es::TASKLIST
  end

  context "The ANSI extension" do
    before(:all) do
      @client = Elasticsearch::Client.new
      @client.stubs(:perform_request).returns \
        Elasticsearch::Transport::Transport::Response.new(200, {
            took: 462,
            timed_out: false,
            _shards: {
              total: 5,
              successful: 5,
              failed: 0
            },
            hits: {
              total: 5,
              max_score: 0,
              hits: []
            }
        })
    end

    it "wrap the response" do
      response = @client.info

      assert_instance_of Elasticsearch::Extensions::ANSI::ResponseBody, response
      assert_instance_of Hash, response.to_hash
    end

    it "extend the response object with `to_ansi`" do
      response = @client.info

      assert_respond_to response, :to_ansi
      assert_instance_of String, response.to_ansi
    end

    it "call the 'awesome_inspect' method when available and no handler found" do
      @client.stubs(:perform_request).returns \
        Elasticsearch::Transport::Transport::Response.new(200, {"index-1"=>{"aliases"=>{}}})
      response = @client.indices.get_aliases

      response.instance_eval do
        def awesome_inspect; "---PRETTY---"; end
      end
      assert_equal '---PRETTY---', response.to_ansi
    end

    it "call `to_s` method when no pretty printer or handler found" do
      @client.stubs(:perform_request).returns \
        Elasticsearch::Transport::Transport::Response.new(200, {"index-1"=>{"aliases"=>{}}})
      response = @client.indices.get_aliases

      assert_equal '{"index-1"=>{"aliases"=>{}}}', response.to_ansi
    end
  end
end
