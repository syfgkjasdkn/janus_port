defmodule Janus do
  @moduledoc File.read!("README.md")

  def info do
    GenServer.call(Janus.Socket, {:send, %{"janus" => "info"}})
  end
end
