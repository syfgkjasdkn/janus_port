defmodule Janus.Socket do
  @moduledoc false
  use GenServer
  require Logger
  defstruct [:socket, :janus_sock, :client_sock, awaiting: %{}]

  @registry Janus.Session.Registry

  @type t :: %__MODULE__{
          # TODO
          socket: port,
          janus_sock: Path.t(),
          client_sock: Path.t(),
          # TODO ets table?
          awaiting: %{(transaction :: String.t()) => GenServer.from()}
        }

  @doc false
  def start_link(config: %Janus.Config{} = config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @doc false
  @spec init(Janus.Config.t()) :: {:ok, t}
  def init(%Janus.Config{client_sock: client_sock, janus_sock: janus_sock}) do
    File.rm(client_sock)
    # TODO fix recbuf hack
    {:ok, socket} = :gen_udp.open(0, [:binary, ip: {:local, client_sock}, recbuf: 999_999])
    # TODO
    {:ok, _} = Registry.start_link(keys: :duplicate, name: @registry)
    {:ok, %__MODULE__{socket: socket, janus_sock: janus_sock, client_sock: client_sock}}
  end

  @doc false
  def handle_call({:send, msg}, from, %{awaiting: awaiting} = state) do
    transaction = _transaction()

    :ok =
      msg
      |> Map.put("transaction", transaction)
      |> _send(state)

    {:noreply, %{state | awaiting: Map.put(awaiting, transaction, from)}}
  end

  @doc false
  def handle_cast({:send, msg}, state) do
    transaction = _transaction()

    :ok =
      msg
      |> Map.put("transaction", transaction)
      |> _send(state)

    {:noreply, state}
  end

  @doc false
  def handle_info(
        {:udp, socket, {:local, janus_sock}, 0, msg},
        %__MODULE__{socket: socket, janus_sock: janus_sock, awaiting: awaiting} = state
      ) do
    case Jason.decode!(msg) do
      %{"janus" => "timeout", "session_id" => session_id} ->
        Logger.debug("session #{session_id} timeout")
        {:noreply, state}

      %{"janus" => "detached", "sender" => handle_id, "session_id" => session_id} ->
        Logger.debug("detached handle #{handle_id} from session #{session_id}")
        {:noreply, state}

      %{"janus" => "ack"} ->
        Logger.debug("got ack")
        {:noreply, state}

      %{"transaction" => transaction} = msg ->
        {maybe_from, awaiting} = Map.pop(awaiting, transaction)
        if maybe_from, do: GenServer.reply(maybe_from, msg)
        {:noreply, %{state | awaiting: awaiting}}

      %{"janus" => janus, "session_id" => session_id} = msg
      when janus in ["media", "webrtcup", "slowlink", "hangup", "event"] ->
        Logger.debug("got event message:\n\n#{inspect(msg)}")
        _broadcast(session_id, msg)
        {:noreply, state}
    end
  end

  @doc false
  def terminate(_reason, %__MODULE__{socket: socket, client_sock: client_sock}) do
    File.rm(client_sock)
    :ok = :gen_udp.close(socket)
    :ok
  end

  @spec _transaction :: String.t()
  defp _transaction do
    8
    |> :crypto.strong_rand_bytes()
    |> Base.encode64(padding: false)
  end

  @spec _send(map, t) :: :ok
  defp _send(msg, %__MODULE__{socket: socket, janus_sock: janus_sock}) do
    :gen_udp.send(socket, {:local, janus_sock}, 0, Jason.encode_to_iodata!(msg))
  end

  @spec _broadcast(Janus.session_id(), map) :: :ok
  defp _broadcast(session_id, message) do
    Registry.dispatch(@registry, session_id, fn entries ->
      Enum.each(entries, fn {pid, _} ->
        send(pid, message)
      end)
    end)
  end
end
