defmodule Janus.Socket do
  @moduledoc false
  use GenServer
  defstruct [:socket, :janus_sock, awaiting: %{}]

  @type t :: %__MODULE__{
          # TODO
          socket: port,
          janus_sock: Path.t(),
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
    {:ok, %__MODULE__{socket: socket, janus_sock: janus_sock}}
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
  def handle_info(
        {:udp, socket, {:local, janus_sock}, 0, msg},
        %__MODULE__{socket: socket, janus_sock: janus_sock, awaiting: awaiting} = state
      ) do
    %{"transaction" => transaction} = msg = Jason.decode!(msg)

    {maybe_from, awaiting} = Map.pop(awaiting, transaction)

    if maybe_from do
      GenServer.reply(maybe_from, msg)
    end

    {:noreply, %{state | awaiting: awaiting}}
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
end
