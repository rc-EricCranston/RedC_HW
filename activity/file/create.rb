require_relative '../../logging/file_log.rb'

def create_file(line, activity, dir_path, file_name)
  # Make the directory and file, rescue if error
  begin
    Dir.mkdir(dir_path) unless Dir.exist?(dir_path)
    
    File.open(dir_path+file_name, 'a+') do |file|
      file.write()
    end
    
    # Add a file activity log
    ruby_process = Sys::ProcTable.ps(pid: Process.pid)
    create_file_log(ruby_process, activity, dir_path+file_name)
  rescue Errno::ENOENT => e
    puts "Error: #{e.message}"
  end
end
