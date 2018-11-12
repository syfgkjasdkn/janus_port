defmodule Janus do
  @moduledoc File.read!("README.md")

  @type session_id :: integer
  @type handle_id :: integer

  @spec info :: map | no_return
  def info do
    _send(%{"janus" => "info"})
  end

  @spec create_session :: map | no_return
  def create_session do
    _send(%{"janus" => "create"})
  end

  @spec destroy_session(session_id) :: map | no_return
  def destroy_session(session_id) do
    _send(%{"janus" => "destroy", "session_id" => session_id})
  end

  @doc """
      
      iex> session_id = 123456789
      iex> %{"data" => %{"id" => handle_id}, "janus" => "success"} = Janus.attach(session_id, "janus.plugin.echotest")
      iex> handle_id
      127635

  """
  @spec attach(session_id, String.t()) :: map | no_return
  def attach(session_id, plugin) do
    _send(%{"janus" => "attach", "session_id" => session_id, "plugin" => plugin})
  end

  @spec detach(session_id, handle_id) :: map | no_return
  def detach(session_id, handle_id) do
    _send(%{"janus" => "detach", "session_id" => session_id, "handle_id" => handle_id})
  end

  @spec send_trickle_candidate(session_id, handle_id, map) :: map | no_return
  def send_trickle_candidate(session_id, handle_id, candidate) do
    _send(%{
      "janus" => "trickle",
      "session_id" => session_id,
      "handle_id" => handle_id,
      "candidate" => candidate
    })
  end

  @spec send_message(session_id, handle_id, map) :: map | no_return
  def send_message(session_id, handle_id, data) do
    %{
      "janus" => "message",
      "session_id" => session_id,
      "handle_id" => handle_id
    }
    |> Map.merge(Map.take(data, ["body", "jsep"]))
    |> _send()
  end

  @spec send_keepalive(session_id) :: map | no_return
  def send_keepalive(session_id) do
    _send(%{"janus" => "keepalive", "session_id" => session_id})
  end

  @compile {:inline, _send: 1}
  defp _send(message) do
    GenServer.call(Janus.Socket, {:send, message})
  end
end
