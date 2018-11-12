defmodule JanusTest do
  use ExUnit.Case

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

    assert %{
             "janus" => "ack",
             "session_id" => ^session_id,
             "transaction" => _transaction
           } = Janus.send_keepalive(session_id)
  end
end
