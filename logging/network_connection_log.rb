def create_network_connection_log(process, source, remote, file_size)
  network_connection_activity_log = 
  { timestamp: Time.now,
  username: process.environ["USER"],
  destination: "#{remote[3]}:#{remote[1]}",
  source: "#{source[3]}:#{source[1]}",
  amount_of_data: file_size,
  protocol: "#{source[0]}",
  process_name: process.comm,
  process_command_line: process.cmdline,
  process_id: process.pid }
  
  log_path = './logging/logs.json'
  
  existing_logs = File.read(log_path) if File.exist?(log_path)
  logs_data = existing_logs ? JSON.parse(existing_logs) : []
  logs_data << network_connection_activity_log
  updated_json = JSON.pretty_generate(logs_data)
  File.open(log_path, 'w') do |file|
    file.write(updated_json)
  end
end
