def create_file_log(process, activity, file_path)
  file_activity_log = 
  { timestamp: Time.now,
  file_path: file_path,
  activity: activity,
  username: process.environ["USER"],
  process_name: process.comm,
  process_command_line: process.cmdline,
  process_id: process.pid }
  
  log_path = './logging/logs.json'
  
  existing_logs = File.read(log_path) if File.exist?(log_path)
  logs_data = existing_logs ? JSON.parse(existing_logs) : []
  logs_data << file_activity_log
  updated_json = JSON.pretty_generate(logs_data)
  File.open(log_path, 'w') do |file|
    file.write(updated_json)
  end
end
