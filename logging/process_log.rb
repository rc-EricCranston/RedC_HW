def create_process_log(process)
  process_activity_log = 
  { timestamp: Time.now,
  username: process.environ["USER"],
  process_name: process.comm,
  process_command_line: process.cmdline,
  process_id: process.pid }
  
  file_path = './logging/logs.json'
  
  existing_logs = File.read(file_path) if File.exist?(file_path)
  logs_data = existing_logs ? JSON.parse(existing_logs) : []
  logs_data << process_activity_log
  updated_json = JSON.pretty_generate(logs_data)
  File.open(file_path, 'w') do |file|
    file.write(updated_json)
  end
end
