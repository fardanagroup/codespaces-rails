# frozen_string_literal: true

require "test_helper"

class ClaudeMcpServiceTest < ActiveSupport::TestCase
  def build(**opts)
    ClaudeMcpService.new(api_key: "test-key", server_url: "https://mcp.example/sse", **opts)
  end

  test "mcp_server carries type, url and the shared server name" do
    server = build.send(:mcp_server)
    assert_equal "url", server[:type]
    assert_equal "https://mcp.example/sse", server[:url]
    assert_equal ClaudeMcpService::SERVER_NAME, server[:name]
  end

  test "mcp_server omits authorization_token when no token is set" do
    server = build(server_token: nil).send(:mcp_server)
    refute server.key?(:authorization_token)
  end

  test "mcp_server includes authorization_token when a token is set" do
    server = build(server_token: "secret").send(:mcp_server)
    assert_equal "secret", server[:authorization_token]
  end

  test "mcp_toolset references the same server name and exposes all tools by default" do
    toolset = build.send(:mcp_toolset)
    assert_equal "mcp_toolset", toolset[:type]
    assert_equal ClaudeMcpService::SERVER_NAME, toolset[:mcp_server_name]
    # No allowlist → no default_config/configs, so every server tool is exposed.
    refute toolset.key?(:default_config)
    refute toolset.key?(:configs)
  end

  test "allowed_tools switches the toolset to allowlist mode" do
    toolset = build(allowed_tools: %w[example_tool_1 example_tool_2]).send(:mcp_toolset)
    assert_equal({ enabled: false }, toolset[:default_config])
    assert_equal(
      [
        { name: "example_tool_1", enabled: true },
        { name: "example_tool_2", enabled: true }
      ],
      toolset[:configs]
    )
  end

  test "call raises a clear error when the server url is missing" do
    service = ClaudeMcpService.new(api_key: "test-key", server_url: nil)
    assert_raises(ArgumentError) { service.call("hi") }
  end
end
