class CommandsController < ApplicationController
	def fetch

		command = params[:command]
		# command = { command }
		
		client = Elasticsearch::Client.new url: 'http://172.18.1.21:9200', log: true

		client.transport.reload_connections!

		client.cluster.health
		
		result = client.search index: 'tw_testing', type: 'tasklist', body: { command.to_s.gsub("\{\"", "{").gsub("\"\=\>", ":") }

		return result
	end
end
