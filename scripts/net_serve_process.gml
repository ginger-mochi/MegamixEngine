/// net_serve_process()
// process network data

var uid = async_load[? "ip"] + ":" + string(async_load[? "port"]);
var type = async_load[? "type"];
var ip = async_load[? "ip"];

if (type == network_type_data)
{
    // new connection
    if (is_undefined(srv_id_connection_map[? uid]))
    {
        srv_id_connection_map[? uid] = srv_connection_count;
        srv_connection_socket_map[srv_connection_count] = async_load[? "socket"];
        srv_connection_ip_map[srv_connection_count] = async_load[? "ip"];
        srv_connection_port_map[srv_connection_count] = async_load[? "port"];
        srv_client_authorized[srv_connection_count] = false;
        srv_connection_count += 1;
        buffer_seek(buff, buffer_seek_start, 0);
        
        // approved (will be recognized) but not yet authorized
        buffer_write(buff, buffer_u8, PTYPE.welcome);
        buffer_write(buff, buffer_u8, RES.approved);
        buffer_write(buff, buffer_string, srv_title);
        network_send_udp(srv_socket, async_load[? "ip"], async_load[? "port"], buff, buffer_tell(buff));
        print("New connection from " + ip + " (connection " + string(uid) + ":" + string(srv_connection_count - 1) + ")", c_lime);
    }
    
    // process data received
    var connection = srv_id_connection_map[? uid];
    if (is_undefined(connection))
    {
        print("Data request from unregistered connection", c_red);
        exit;
    }
    var in_buff = async_load[? "buffer"];
    var in_buff_size = async_load[? "size"];
    if (in_buff_size == 0)
        exit;
    buffer_seek(in_buff, buffer_seek_start, 0);
    buffer_seek(buff, buffer_seek_start, 0);
    var out_socket = srv_socket;
    if (!buffer_has(in_buff, 2))
        exit;
    var packet_type = buffer_read(in_buff, buffer_u8);
    
    // name to refer to client as in the logs
    cli_log_name = uid;
    
    if (!srv_client_authorized[connection] && packet_type != PTYPE.request_players)
        exit;
    
    switch (packet_type)
    {
        case PTYPE.request_players: // client wants more players 
            if (!buffer_has(in_buff, 1))
                exit;
            var add_players = buffer_read(in_buff, buffer_u8);
            
            // TODO: safe reading of strings from potentially malicious buffer
            var pwd = buffer_read(in_buff, buffer_string);
            if (!(srv_password == "" || pwd == srv_password))
            {
                print("Client " + cli_log_name + " could not authenticate.", c_red);
                buffer_write(buff, buffer_u8, RES.rejected_unauthorized);
                break;
            }
            if (add_players < 0)
            {
                print("Client " + cli_log_name + " requested negative players...?", c_red);
                buffer_write(buff, buffer_8, RES.rejected);
                break;
            }
            srv_client_authorized[connection] = true;
            ncmd_tiles_timer = 10;
            buffer_write(buff, buffer_u8, PTYPE.request_players);
            if (srv_maxPlayers < 0 || srv_player_count + add_players <= srv_maxPlayers)
            {
                buffer_write(buff, buffer_u8, RES.approved);
                for (j = srv_player_count; j < srv_player_count + add_players; j++)
                {
                    srv_player_connection_map[j] = connection;
                    buffer_write(buff, buffer_u16, j);
                    srv_p_input[j] = 0;
                    print("Player no. " + string(j) + " registered in connection no. " + string(connection), c_green);
                    global.respawnTimer[j] = 0;
                }
                srv_player_count += add_players;
                global.playerCount = srv_player_count;
                playerGlobalInit();
                ncmd_tiles();
            }
            else
            {
                buffer_write(buff, buffer_u8, RES.rejected);
                print("Client " + cli_log_name + " requested too many player slots.", c_red);
            }
            break;
        case PTYPE.controller: // client gives controller input 
            if (!buffer_has(in_buff, 2))
                exit;
            var p = buffer_read(in_buff, buffer_u16);
            if (srv_player_connection_map[p] == connection)
            {
                if (!buffer_has(in_buff, 4))
                    exit;
                srv_p_input_n = max(p + 1, srv_p_input_n);
                srv_p_input[p] = buffer_read(in_buff, buffer_u32);
            }
            else
                break;
            break;
        case PTYPE.ping: // send the byte back to the client 
            if (!buffer_has(in_buff, 1))
                exit;
            buffer_write(buff, buffer_u8, PTYPE.ping);
            buffer_write(buff, buffer_u8, buffer_read(in_buff, buffer_u8));
            break;
        case PTYPE.skin: // client wants to change their skin 
            if (!buffer_has(in_buff, 2))
                exit;
            var p = buffer_read(in_buff, buffer_u16);
            if (srv_player_connection_map[p] == connection)
            {
                if (!buffer_has(in_buff, 1))
                    exit;
                var skin = buffer_read(in_buff, buffer_u8);
                // TODO
            }
            else
                break;
            break;
        default:
            exit;
    }
    
    // response
    if (buffer_tell(buff) > 0)
        server_send_udp(connection, buff, buffer_tell(buff));
}

