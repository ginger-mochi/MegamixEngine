/// server_send_udp(connection, buffer, size)
/// sends the buffer to the given connection id (1 to connectionCout)

var cli_id = argument0;
network_send_udp(objNet.srv_socket,
                 objNet.srv_connection_ip_map[cli_id],
                 objNet.srv_connection_port_map[cli_id],
                 argument1,
                 argument2)