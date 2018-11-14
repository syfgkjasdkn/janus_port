defmodule JanusTest do
  use ExUnit.Case

  setup_all do
    {:ok, _pid} =
      Janus.Socket.start_link(
        config: %Janus.Config{
          binary_path: "/opt/janus/bin/janus",
          client_sock: "/home/vagrant/elixir.sock",
          janus_sock: "/home/vagrant/janus.sock"
        }
      )

    :ok
  end

  @tag real_janus: true
  test "create and destroy a session" do
    assert %{
             "data" => %{"id" => session_id},
             "janus" => "success",
             "transaction" => _transaction
           } = Janus.create_session()

    assert %{
             "janus" => "success",
             "session_id" => ^session_id,
             "transaction" => _transaction
           } = Janus.destroy_session(session_id)
  end

  @tag real_janus: true
  test "attach and detach plugin to a session" do
    assert %{
             "data" => %{"id" => session_id},
             "janus" => "success",
             "transaction" => _transaction
           } = Janus.create_session()

    assert %{
             "data" => %{"id" => handle_id},
             "janus" => "success",
             "session_id" => ^session_id,
             "transaction" => _transaction
           } = Janus.attach(session_id, "janus.plugin.echotest")

    assert %{
             "janus" => "success",
             "session_id" => ^session_id,
             "transaction" => _transaction
           } = Janus.detach(session_id, handle_id)
  end

  @tag real_janus: true
  test "send keepalive for a session" do
    assert %{
             "data" => %{"id" => session_id},
             "janus" => "success",
             "transaction" => _transaction
           } = Janus.create_session()

    # TODO
    assert :ok = Janus.send_keepalive(session_id)
  end

  @tag real_janus: true
  test "send echotest plugin message" do
    assert %{
             "data" => %{"id" => session_id},
             "janus" => "success",
             "transaction" => _transaction
           } = Janus.create_session()

    assert %{
             "data" => %{"id" => handle_id},
             "janus" => "success",
             "session_id" => ^session_id,
             "transaction" => _transaction
           } = Janus.attach(session_id, "janus.plugin.echotest")

    assert %{
             "janus" => "event",
             "plugindata" => %{
               "data" => %{"echotest" => "event", "result" => "ok"},
               "plugin" => "janus.plugin.echotest"
             },
             "sender" => ^handle_id,
             "session_id" => ^session_id,
             "transaction" => _transaction
           } =
             Janus.send_message(session_id, handle_id, %{
               "body" => %{"audio" => true, "video" => true}
             })
  end
end
