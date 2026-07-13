# frozen_string_literal: true

# ClaudeMcpService calls the Claude Messages API with a remote MCP server
# attached via the MCP connector (beta).
#
# The MCP connector lets Claude call tools hosted on a remote MCP server
# directly from a single Messages API request — Anthropic makes the MCP
# connection server-side, so there is nothing to run on our end.
#
# Two request pieces are required and must agree on the server name:
#   * mcp_servers      — the connection: {type:, url:, name:, authorization_token:}
#   * tools            — an {type: "mcp_toolset", mcp_server_name:} entry that
#                        references that server by name (the API rejects an
#                        mcp_servers entry that no toolset points at)
# and the beta flag "mcp-client-2025-11-20" on client.beta.messages.create.
#
# Usage:
#   ClaudeMcpService.new.call("What tools can you use? List them.")
#
# Configuration (all via ENV so no secrets live in the repo):
#   ANTHROPIC_API_KEY   — required; the Anthropic API key
#   MCP_SERVER_URL      — the remote MCP server endpoint (Streamable HTTP / SSE)
#   MCP_SERVER_TOKEN    — optional bearer token forwarded to the MCP server
class ClaudeMcpService
  # Model + betas per the Claude API skill (claude-opus-4-8 is the default;
  # the MCP connector is gated behind this beta flag).
  DEFAULT_MODEL = :"claude-opus-4-8"
  MCP_BETA = "mcp-client-2025-11-20"

  # Name that ties the mcp_servers entry to the mcp_toolset entry. It is an
  # internal handle only — any stable string works, but the two must match.
  SERVER_NAME = "example-mcp"

  Result = Struct.new(:text, :stop_reason, :message, keyword_init: true)

  # allowed_tools: restrict Claude to a subset of the server's tools. Pass nil
  # (the default) to expose every tool the server offers. Passing an array
  # switches the toolset to allowlist mode (disable-all, then opt each one in).
  def initialize(
    api_key: ENV["ANTHROPIC_API_KEY"],
    server_url: ENV["MCP_SERVER_URL"],
    server_token: ENV["MCP_SERVER_TOKEN"],
    allowed_tools: nil,
    model: DEFAULT_MODEL
  )
    @client = Anthropic::Client.new(api_key: api_key)
    @server_url = server_url
    @server_token = server_token
    @allowed_tools = allowed_tools
    @model = model
  end

  # Sends a single user message and returns the assistant's text response.
  #
  # prompt      — the user's message (String)
  # max_tokens  — output cap; ~16k is a safe non-streaming default (see skill)
  def call(prompt, max_tokens: 16_000)
    raise ArgumentError, "MCP_SERVER_URL is not configured" if @server_url.to_s.empty?

    message = @client.beta.messages.create(
      model: @model,
      max_tokens: max_tokens,
      betas: [MCP_BETA],
      mcp_servers: [mcp_server],
      tools: [mcp_toolset],
      messages: [{ role: "user", content: prompt }]
    )

    Result.new(
      text: extract_text(message),
      stop_reason: message.stop_reason,
      message: message
    )
  end

  private

  # The MCP server connection. authorization_token is only included when a
  # token is present, so anonymous/public servers work too.
  def mcp_server
    server = { type: "url", url: @server_url, name: SERVER_NAME }
    server[:authorization_token] = @server_token unless @server_token.to_s.empty?
    server
  end

  # The toolset that grants Claude access to the server declared above. When
  # allowed_tools is given, flip the default off and opt each named tool in —
  # this is the allowlist equivalent of the pasted config's `allowed_tools`.
  def mcp_toolset
    toolset = { type: "mcp_toolset", mcp_server_name: SERVER_NAME }
    if @allowed_tools
      toolset[:default_config] = { enabled: false }
      toolset[:configs] = @allowed_tools.map { |name| { name: name, enabled: true } }
    end
    toolset
  end

  # content is an array of polymorphic blocks (text, mcp_tool_use,
  # mcp_tool_result, ...). .type is a Symbol, and .text only exists on text
  # blocks — so guard on the type before reading it.
  def extract_text(message)
    message.content.filter_map { |block| block.text if block.type == :text }.join("\n")
  end
end
