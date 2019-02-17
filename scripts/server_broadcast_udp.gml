/// server_broadcast_udp(buffer, size)
/// sends buffer to every connected client (except self)

for (var i=1;i<objNet.srv_connection_count;i++) {
    server_send_udp(i,argument0,argument1);
}