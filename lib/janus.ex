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

  @spec attach(session_id, String.t()) :: map | no_return
  def attach(session_id, plugin) do
    _send(%{"janus" => "attach", "session_id" => session_id, "plugin" => plugin})
  end

  @spec detach(session_id, handle_id) :: map | no_return
  def detach(session_id, handle_id) do
    _send(%{"janus" => "detach", "session_id" => session_id, "handle_id" => handle_id})
  end

  # TODO simplify
  @spec send_trickle_candidate(session_id, handle_id, [map] | map | nil) :: map | no_return
  def send_trickle_candidate(session_id, handle_id, maybe_candidates) do
    message = %{
      "janus" => "trickle",
      "session_id" => session_id,
      "handle_id" => handle_id
    }

    message =
      case maybe_candidates do
        candidates when is_list(candidates) ->
          Map.put(message, "candidates", candidates)

        candidate ->
          Map.put(message, "candidate", candidate)
      end

    _send(message)
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

  @spec send_keepalive(session_id) :: :ok
  def send_keepalive(session_id) do
    # TODO
    GenServer.cast(Janus.Socket, {:send, %{"janus" => "keepalive", "session_id" => session_id}})
  end

  @compile {:inline, _send: 1}
  @spec _send(map) :: map | no_return
  defp _send(message) do
    GenServer.call(Janus.Socket, {:send, message})
  end
end
