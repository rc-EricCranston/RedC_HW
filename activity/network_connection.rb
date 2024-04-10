require 'socket'
require_relative '../logging/network_connection_log'

def network_connection(command, activity, server_address, server_port, file_path)
  port = server_port.to_i
  file_size = File.size(file_path)
  
  # Connect to the server
  client = TCPSocket.new(server_address, port)
  
  # Get the source and destination address and port
  local_address = client.addr
  remote_address = client.peeraddr
  
  # Send the file size to the server
  client.puts file_size.to_s
  
  # Read the file and send to the server
  File.open(file_path, 'rb') do |file|
    while chunk = file.read(1024)
      client.write(chunk)
    end
  end
  
  # Receive confirmation from the server
  confirmation = client.gets.chomp
  puts "Server response: #{confirmation}"
  
  # Close the connection to the server
  client.close
  
  # Add a network connection activity log
  ruby_process = Sys::ProcTable.ps(pid: Process.pid)
  create_network_connection_log(ruby_process, local_address, remote_address, file_size)
end
