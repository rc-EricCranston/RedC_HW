require_relative '../../logging/file_log.rb'

def delete_file(command, activity, file_path)
  # Delete file, rescue if error
  begin
    File.delete(file_path)
    
    # Add a file activity log
    ruby_process = Sys::ProcTable.ps(pid: Process.pid)
    create_file_log(ruby_process, activity, file_path)
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
  end
end
