require 'json'
require 'socket'
require 'sys/proctable'

def main(input_file)
  # Create a process activity log
  ruby_process = Sys::ProcTable.ps(pid: Process.pid)
  
  process_activity_log = 
  { timestamp: Time.now,
  username: ruby_process.environ["USER"],
  process_name: ruby_process.comm,
  process_command_line: ruby_process.cmdline,
  process_id: ruby_process.pid }
  
  file_path = './logs.json'
  
  existing_logs = File.read(file_path) if File.exist?(file_path)
  logs_data = existing_logs ? JSON.parse(existing_logs) : []
  logs_data << process_activity_log
  updated_json = JSON.pretty_generate(logs_data)
  File.open(file_path, 'w') do |file|
    file.write(updated_json)
  end
  
  # Parse activity in input file
  File.foreach(input_file) do |line|
    line.chomp!
    line_args = line.split(",")
    case line_args[0]
    when "create"
      create_file(line, line_args[0], line_args[1], line_args[2])
    when "modify"
      modify_file(line, line_args[0], line_args[1], line_args[2])
    when "delete"
      delete_file(line, line_args[0], line_args[1])
    when "network connection"
      network_connection(line, line_args[0], line_args[1], line_args[2], line_args[3])
    when "open"
      open_app(line, line_args[0], line_args[1])
    end
  end
end

def open_app(command, activity, application)
  open_app_command = "open -a #{application}"
  app_pid = Process.spawn(open_app_command)
  app_process = Sys::ProcTable.ps(pid: app_pid)
  
  # Create a process activity log
  process_activity_log = 
  { timestamp: Time.now,
  username: app_process.environ["USER"],
  process_name: app_process.comm,
  process_command_line: app_process.cmdline,
  process_id: app_process.pid }
  
  file_path = './logs.json'
  
  existing_logs = File.read(file_path) if File.exist?(file_path)
  logs_data = existing_logs ? JSON.parse(existing_logs) : []
  logs_data << process_activity_log
  updated_json = JSON.pretty_generate(logs_data)
  File.open(file_path, 'w') do |file|
    file.write(updated_json)
  end
end

def create_file(line, activity, dir_path, file_name)
  # Make the directory and file, rescue if error
  begin
    Dir.mkdir(dir_path) unless Dir.exist?(dir_path)
    
    File.open(dir_path+file_name, 'a+') do |file|
      file.write()
    end
    
    # Add a file activity log
    ruby_process = Sys::ProcTable.ps(pid: Process.pid)
    
    create_file_activity_log = 
    { timestamp: Time.now,
    file_path: dir_path+file_name,
    activity: activity,
    username: ruby_process.environ["USER"],
    process_name: ruby_process.comm,
    process_command_line: ruby_process.cmdline,
    process_id: ruby_process.pid }
    
    log_path = './logs.json'
    
    existing_logs = File.read(log_path) if File.exist?(log_path)
    logs_data = existing_logs ? JSON.parse(existing_logs) : []
    logs_data << create_file_activity_log
    updated_json = JSON.pretty_generate(logs_data)
    File.open(log_path, 'w') do |file|
      file.write(updated_json)
    end
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
  end
end

def modify_file(command, activity, file_path, added_text)
  # Add text to end of file, rescue if error
  begin
    File.open(file_path, 'r+') do |file|
      existing_data = file.read
      updated_data = existing_data.chomp + "\n" + added_text
      file.rewind
      file.write(updated_data)
    end
    
    # Add a file activity log
    ruby_process = Sys::ProcTable.ps(pid: Process.pid)
    
    modify_file_activity_log = 
    { timestamp: Time.now,
    full_path: file_path,
    activity: activity,
    username: ruby_process.environ["USER"],
    process_name: ruby_process.comm,
    process_command_line: ruby_process.cmdline,
    process_id: ruby_process.pid }
    
    log_path = './logs.json'
    
    existing_logs = File.read(log_path) if File.exist?(log_path)
    logs_data = existing_logs ? JSON.parse(existing_logs) : []
    logs_data << modify_file_activity_log
    updated_json = JSON.pretty_generate(logs_data)
    File.open(log_path, 'w') do |file|
      file.write(updated_json)
    end
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
  end
end

def delete_file(command, activity, file_path)
  # Delete the file, rescue if error
  begin
    File.delete(file_path)
    
    # Add a file activity log
    ruby_process = Sys::ProcTable.ps(pid: Process.pid)
    
    delete_file_activity_log = 
    { timestamp: Time.now,
    full_path: file_path,
    activity: activity,
    username: ruby_process.environ["USER"],
    process_name: ruby_process.comm,
    process_command_line: ruby_process.cmdline,
    process_id: ruby_process.pid }
    
    log_path = './logs.json'
    
    existing_logs = File.read(log_path) if File.exist?(log_path)
    logs_data = existing_logs ? JSON.parse(existing_logs) : []
    logs_data << delete_file_activity_log
    updated_json = JSON.pretty_generate(logs_data)
    File.open(log_path, 'w') do |file|
      file.write(updated_json)
    end
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
  end
  
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
end