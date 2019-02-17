/// server_start

with objNet {
    if objNet.srv_isServing
        return -2;
        
    if objNet.cli_status !=0
        return -3;
    
    if objNet.srv_title == ""
        return -4;
    
    if objNet.srv_maxConnections < 0 || objNet.srv_maxConnections > 240
        objNet.srv_maxConnections = 240;
    objNet.srv_port = real(string(objNet.srv_port));
    objNet.srv_socket = network_create_server(objNet.SOCKET_TYPE,objNet.srv_port,objNet.srv_maxConnections)
    if objNet.srv_socket >= 0 {
        objNet.srv_isServing = true;
        objNet.srv_isAccepting = true;
        objNet.srv_connection_count = 1;
        objNet.srv_connection_socket_map[0] = -1;
        objNet.loc_player_count = global.playerCount;
        objNet.srv_player_count = objNet.loc_player_count;
        objNet.srv_p_input_n = 0;
        for (var i=0; i < objNet.loc_player_count; i+= 1) {
            objNet.srv_player_connection_map[i] = 0;
            objNet.loc_player_ids[i] = i;
            objNet.loc_forwardControl_ids[i] = i;
        }
        objNet.buff = buffer_create( 1024, buffer_grow, 1);
        print("Server started on port " + string(objNet.srv_port))
        return 0;
    }
    
    return -1;
}
