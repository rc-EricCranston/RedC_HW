require_relative '../../logging/file_log.rb'

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
    create_file_log(ruby_process, activity, file_path)
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
  end
end
