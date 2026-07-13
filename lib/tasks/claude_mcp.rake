# frozen_string_literal: true

# Runnable entry point that exercises ClaudeMcpService against a live MCP server.
#
#   ANTHROPIC_API_KEY=sk-... \
#   MCP_SERVER_URL=https://your-mcp-server/sse \
#   MCP_SERVER_TOKEN=optional-token \
#   bin/rails "claude:mcp[What tools can you use?]"
#
# The prompt argument is optional and defaults to a tool-discovery question.
namespace :claude do
  desc "Send a prompt to Claude with the configured remote MCP server attached"
  task :mcp, [:prompt] => :environment do |_task, args|
    prompt = args[:prompt].presence || "List the tools you have access to and what each one does."

    result = ClaudeMcpService.new.call(prompt)

    puts "stop_reason: #{result.stop_reason}"
    puts "---"
    puts result.text
  end
end
