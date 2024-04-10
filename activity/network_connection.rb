require 'socket'

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
  
  network_connection_file_activity_log = 
  { timestamp: Time.now,
  username: ruby_process.environ["USER"],
  destination: "#{remote_address[3]}:#{remote_address[1]}",
  source: "#{local_address[3]}:#{local_address[1]}",
  amount_of_data: file_size,
  protocol: "#{local_address[0]}",
  process_name: ruby_process.comm,
  process_command_line: ruby_process.cmdline,
  process_id: ruby_process.pid }
  
  log_path = './logs.json'
  
  existing_logs = File.read(log_path) if File.exist?(log_path)
  logs_data = existing_logs ? JSON.parse(existing_logs) : []
  logs_data << network_connection_file_activity_log
  updated_json = JSON.pretty_generate(logs_data)
  File.open(log_path, 'w') do |file|
    file.write(updated_json)
  end
end
