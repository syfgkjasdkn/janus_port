defmodule Janus.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      {Janus.Socket,
       config: %Janus.Config{
         binary_path: "/opt/janus/bin/janus",
         client_sock: "/home/vagrant/elixir.sock",
         janus_sock: "/home/vagrant/janus.sock"
       }}
    ]

    opts = [strategy: :one_for_one, name: Janus.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
