defmodule Janus.Config do
  @moduledoc false
  defstruct [:client_sock, :janus_sock]

  @type t :: %__MODULE__{
          client_sock: Path.t(),
          janus_sock: Path.t()
        }

  @spec build! :: t | no_return
  def build! do
    %__MODULE__{
      client_sock: get_env!(:client_sock),
      janus_sock: get_env!(:janus_sock)
    }
  end

  @spec get_env!(atom) :: term | no_return
  defp get_env!(key) do
    Application.get_env(:janus_port, key) || raise("need #{key} to be set for :janus_port")
  end
end
