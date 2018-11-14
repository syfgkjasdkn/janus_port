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

  # TODO
  @jsep %{
    "type" => "offer",
    "sdp" =>
      "v=0\r\no=- 3006640610927295490 2 IN IP4 127.0.0.1\r\ns=-\r\nt=0 0\r\na=group:BUNDLE audio video\r\na=msid-semantic: WMS 8Ebh7qySsv3vCf81DUv7q8qp5GXXZJFBtUui\r\nm=audio 54765 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126\r\nc=IN IP4 159.65.119.183\r\na=rtcp:9 IN IP4 0.0.0.0\r\na=candidate:694132342 1 udp 2122260223 192.168.1.43 61429 typ host generation 0 network-id 1 network-cost 10\r\na=candidate:3601758585 1 udp 2122194687 10.8.0.22 54765 typ host generation 0 network-id 2 network-cost 50\r\na=candidate:1742496390 1 tcp 1518280447 192.168.1.43 9 typ host tcptype active generation 0 network-id 1 network-cost 10\r\na=candidate:2553120137 1 tcp 1518214911 10.8.0.22 9 typ host tcptype active generation 0 network-id 2 network-cost 50\r\na=candidate:2485356529 1 udp 1685987071 159.65.119.183 54765 typ srflx raddr 10.8.0.22 rport 54765 generation 0 network-id 2 network-cost 50\r\na=ice-ufrag:9odQ\r\na=ice-pwd:bv7AlcsIJDZrOHzDnAQuXgBG\r\na=ice-options:trickle\r\na=fingerprint:sha-256 0D:0F:5C:10:07:C7:08:C7:AA:ED:C1:B3:DA:08:38:E8:25:CE:87:25:81:39:2B:58:5E:8E:CB:66:AC:15:26:69\r\na=setup:actpass\r\na=mid:audio\r\na=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level\r\na=sendrecv\r\na=rtcp-mux\r\na=rtpmap:111 opus/48000/2\r\na=rtcp-fb:111 transport-cc\r\na=fmtp:111 minptime=10;useinbandfec=1\r\na=rtpmap:103 ISAC/16000\r\na=rtpmap:104 ISAC/32000\r\na=rtpmap:9 G722/8000\r\na=rtpmap:0 PCMU/8000\r\na=rtpmap:8 PCMA/8000\r\na=rtpmap:106 CN/32000\r\na=rtpmap:105 CN/16000\r\na=rtpmap:13 CN/8000\r\na=rtpmap:110 telephone-event/48000\r\na=rtpmap:112 telephone-event/32000\r\na=rtpmap:113 telephone-event/16000\r\na=rtpmap:126 telephone-event/8000\r\na=ssrc:2117926308 cname:vhgiJQ3n1dW9qyEh\r\na=ssrc:2117926308 msid:8Ebh7qySsv3vCf81DUv7q8qp5GXXZJFBtUui 6878aac4-8953-4fd8-b119-54b99ff2e2b3\r\na=ssrc:2117926308 mslabel:8Ebh7qySsv3vCf81DUv7q8qp5GXXZJFBtUui\r\na=ssrc:2117926308 label:6878aac4-8953-4fd8-b119-54b99ff2e2b3\r\nm=video 55951 UDP/TLS/RTP/SAVPF 96 97 98 99 100 101 102 122 127 121 125 107 108 109 124 120 123 119 114\r\nc=IN IP4 159.65.119.183\r\na=rtcp:9 IN IP4 0.0.0.0\r\na=candidate:694132342 1 udp 2122260223 192.168.1.43 52977 typ host generation 0 network-id 1 network-cost 10\r\na=candidate:3601758585 1 udp 2122194687 10.8.0.22 55951 typ host generation 0 network-id 2 network-cost 50\r\na=candidate:1742496390 1 tcp 1518280447 192.168.1.43 9 typ host tcptype active generation 0 network-id 1 network-cost 10\r\na=candidate:2553120137 1 tcp 1518214911 10.8.0.22 9 typ host tcptype active generation 0 network-id 2 network-cost 50\r\na=candidate:2485356529 1 udp 1685987071 159.65.119.183 55951 typ srflx raddr 10.8.0.22 rport 55951 generation 0 network-id 2 network-cost 50\r\na=ice-ufrag:9odQ\r\na=ice-pwd:bv7AlcsIJDZrOHzDnAQuXgBG\r\na=ice-options:trickle\r\na=fingerprint:sha-256 0D:0F:5C:10:07:C7:08:C7:AA:ED:C1:B3:DA:08:38:E8:25:CE:87:25:81:39:2B:58:5E:8E:CB:66:AC:15:26:69\r\na=setup:actpass\r\na=mid:video\r\na=extmap:2 urn:ietf:params:rtp-hdrext:toffset\r\na=extmap:3 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time\r\na=extmap:4 urn:3gpp:video-orientation\r\na=extmap:5 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01\r\na=extmap:6 http://www.webrtc.org/experiments/rtp-hdrext/playout-delay\r\na=extmap:7 http://www.webrtc.org/experiments/rtp-hdrext/video-content-type\r\na=extmap:8 http://www.webrtc.org/experiments/rtp-hdrext/video-timing\r\na=sendrecv\r\na=rtcp-mux\r\na=rtcp-rsize\r\na=rtpmap:96 VP8/90000\r\na=rtcp-fb:96 goog-remb\r\na=rtcp-fb:96 transport-cc\r\na=rtcp-fb:96 ccm fir\r\na=rtcp-fb:96 nack\r\na=rtcp-fb:96 nack pli\r\na=rtpmap:97 rtx/90000\r\na=fmtp:97 apt=96\r\na=rtpmap:98 VP9/90000\r\na=rtcp-fb:98 goog-remb\r\na=rtcp-fb:98 transport-cc\r\na=rtcp-fb:98 ccm fir\r\na=rtcp-fb:98 nack\r\na=rtcp-fb:98 nack pli\r\na=fmtp:98 x-google-profile-id=0\r\na=rtpmap:99 rtx/90000\r\na=fmtp:99 apt=98\r\na=rtpmap:100 H264/90000\r\na=rtcp-fb:100 goog-remb\r\na=rtcp-fb:100 transport-cc\r\na=rtcp-fb:100 ccm fir\r\na=rtcp-fb:100 nack\r\na=rtcp-fb:100 nack pli\r\na=fmtp:100 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42001f\r\na=rtpmap:101 rtx/90000\r\na=fmtp:101 apt=100\r\na=rtpmap:102 H264/90000\r\na=rtcp-fb:102 goog-remb\r\na=rtcp-fb:102 transport-cc\r\na=rtcp-fb:102 ccm fir\r\na=rtcp-fb:102 nack\r\na=rtcp-fb:102 nack pli\r\na=fmtp:102 level-asymmetry-allowed=1;packetization-mode=0;profile-level-id=42001f\r\na=rtpmap:122 rtx/90000\r\na=fmtp:122 apt=102\r\na=rtpmap:127 H264/90000\r\na=rtcp-fb:127 goog-remb\r\na=rtcp-fb:127 transport-cc\r\na=rtcp-fb:127 ccm fir\r\na=rtcp-fb:127 nack\r\na=rtcp-fb:127 nack pli\r\na=fmtp:127 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f\r\na=rtpmap:121 rtx/90000\r\na=fmtp:121 apt=127\r\na=rtpmap:125 H264/90000\r\na=rtcp-fb:125 goog-remb\r\na=rtcp-fb:125 transport-cc\r\na=rtcp-fb:125 ccm fir\r\na=rtcp-fb:125 nack\r\na=rtcp-fb:125 nack pli\r\na=fmtp:125 level-asymmetry-allowed=1;packetization-mode=0;profile-level-id=42e01f\r\na=rtpmap:107 rtx/90000\r\na=fmtp:107 apt=125\r\na=rtpmap:108 H264/90000\r\na=rtcp-fb:108 goog-remb\r\na=rtcp-fb:108 transport-cc\r\na=rtcp-fb:108 ccm fir\r\na=rtcp-fb:108 nack\r\na=rtcp-fb:108 nack pli\r\na=fmtp:108 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=4d0032\r\na=rtpmap:109 rtx/90000\r\na=fmtp:109 apt=108\r\na=rtpmap:124 H264/90000\r\na=rtcp-fb:124 goog-remb\r\na=rtcp-fb:124 transport-cc\r\na=rtcp-fb:124 ccm fir\r\na=rtcp-fb:124 nack\r\na=rtcp-fb:124 nack pli\r\na=fmtp:124 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=640032\r\na=rtpmap:120 rtx/90000\r\na=fmtp:120 apt=124\r\na=rtpmap:123 red/90000\r\na=rtpmap:119 rtx/90000\r\na=fmtp:119 apt=123\r\na=rtpmap:114 ulpfec/90000\r\na=ssrc-group:FID 38997453 4060400986\r\na=ssrc:38997453 cname:vhgiJQ3n1dW9qyEh\r\na=ssrc:38997453 msid:8Ebh7qySsv3vCf81DUv7q8qp5GXXZJFBtUui 64cfdd71-ced4-456b-a218-167154dcb287\r\na=ssrc:38997453 mslabel:8Ebh7qySsv3vCf81DUv7q8qp5GXXZJFBtUui\r\na=ssrc:38997453 label:64cfdd71-ced4-456b-a218-167154dcb287\r\na=ssrc:4060400986 cname:vhgiJQ3n1dW9qyEh\r\na=ssrc:4060400986 msid:8Ebh7qySsv3vCf81DUv7q8qp5GXXZJFBtUui 64cfdd71-ced4-456b-a218-167154dcb287\r\na=ssrc:4060400986 mslabel:8Ebh7qySsv3vCf81DUv7q8qp5GXXZJFBtUui\r\na=ssrc:4060400986 label:64cfdd71-ced4-456b-a218-167154dcb287\r\n"
  }

  @candidate %{
    "candidate" =>
      "candidate:2485356529 1 udp 1685987071 159.65.119.183 55951 typ srflx raddr 10.8.0.22 rport 55951 generation 0 ufrag 9odQ network-id 2 network-cost 50",
    "sdpMid" => "video",
    "sdpMLineIndex" => 1
  }

  @tag real_janus: true
  test "send echotest plugin message and trickle candidate" do
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
             "jsep" => %{
               "sdp" => sdp,
               "type" => "answer"
             },
             "plugindata" => %{
               "data" => %{"echotest" => "event", "result" => "ok"},
               "plugin" => "janus.plugin.echotest"
             },
             "sender" => ^handle_id,
             "session_id" => ^session_id,
             "transaction" => _transaction
           } =
             Janus.send_message(session_id, handle_id, %{
               "jsep" => @jsep,
               "body" => %{"audio" => true, "video" => true}
             })

    # "v=0\r\no=- 3006640610927295490 2 IN IP4 10.0.2.15\r\ns=-\r\nt=0 0\r\na=group:BUNDLE audio video\r\na=msid-semantic: WMS janus\r\nm=audio 9 UDP/TLS/RTP/SAVPF 111\r\nc=IN IP4 10.0.2.15\r\na=sendrecv\r\na=mid:audio\r\na=rtcp-mux\r\na=ice-ufrag:eV7c\r\na=ice-pwd:T/9F2aZgOz+5u1nRCGR1AO\r\na=ice-options:trickle\r\na=fingerprint:sha-256 D2:B9:31:8F:DF:24:D8:0E:ED:D2:EF:25:9E:AF:6F:B8:34:AE:53:9C:E6:F3:8F:F2:64:15:FA:E8:7F:53:2D:38\r\na=setup:active\r\na=rtpmap:111 opus/48000/2\r\na=ssrc:1967669716 cname:janusaudio\r\na=ssrc:1967669716 msid:janus janusa0\r\na=ssrc:1967669716 mslabel:janus\r\na=ssrc:1967669716 label:janusa0\r\na=candidate:1 1 udp 2013266431 10.0.2.15 48969 typ host\r\na=end-of-candidates\r\nm=video 9 UDP/TLS/RTP/SAVPF 96\r\nc=IN IP4 10.0.2.15\r\na=sendrecv\r\na=mid:video\r\na=rtcp-mux\r\na=ice-ufrag:eV7c\r\na=ice-pwd:T/9F2aZgOz+5u1nRCGR1AO\r\na=ice-options:trickle\r\na=fingerprint:sha-256 D2:B9:31:8F:DF:24:D8:0E:ED:D2:EF:25:9E:AF:6F:B8:34:AE:53:9C:E6:F3:8F:F2:64:15:FA:E8:7F:53:2D:38\r\na=setup:active\r\na=rtpmap:96 VP8/90000\r\na=rtcp-fb:96 ccm fir\r\na=rtcp-fb:96 nack\r\na=rtcp-fb:96 nack pli\r\na=rtcp-fb:96 goog-remb\r\na=rtcp-fb:96 transport-cc\r\na=ssrc:2951739989 cname:janusvideo\r\na=ssrc:2951739989 msid:janus janusv0\r\na=ssrc:2951739989 mslabel:janus\r\na=ssrc:2951739989 label:janusv0\r\na=candidate:1 1 udp 2013266431 10.0.2.15 48969 typ host\r\na=end-of-candidates\r\n"

    sdp = String.split(sdp)

    # TODO
    assert "v=0" in sdp
    assert "janus" in sdp

    # TODO
    assert :ok = Janus.send_trickle_candidate(session_id, handle_id, @candidate)
    assert :ok = Janus.send_trickle_candidate(session_id, handle_id, %{"completed" => true})

    # TODO
    # refute_receive :a, 10_000
  end
end
