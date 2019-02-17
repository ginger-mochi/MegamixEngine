/// client_join()

with objNet {
    if objNet.cli_status != 0
        return -1;
    if objNet.srv_isServing
        return -2;
        
    objNet.cli_socket = network_create_socket(objNet.SOCKET_TYPE);
    if cli_socket < 0
        return -3;
    objNet.cli_status = 2; // joining...
    objNet.cli_authorized = false;
    objNet.buff = buffer_create( 256, buffer_grow, 1);
    
    buffer_seek(buff, buffer_seek_start, 0);
    buffer_write(buff, buffer_u8, PTYPE.request_players );
    buffer_write(buff, buffer_u8, global.playerCount);
    buffer_write(buff, buffer_string, cli_host_password);
    var tell = buffer_tell(buff);
    buffer_seek(buff, buffer_seek_start, 0);
    objNet.cli_host_port = real(string(objNet.cli_host_port));
    if network_send_udp(cli_socket, objNet.cli_host_url, objNet.cli_host_port, buff, tell) < 0 {
        print("Failed to send UDP packet.", c_red);
        objNet.cli_status = 0;
        return -9;
    }
    
    print("Attempting to join server " + string(objNet.cli_host_url) + ":" + string(objNet.cli_host_port) + "...")
    
    return 0;
}
