require 'socket'

# Define the port number to listen on
port = 3000

# Create a server
server = TCPServer.new(port)
puts "Server is listening on port #{port}"

# File name counter
file_num = 1

# Accept incoming connections
loop do
  client = server.accept
  
  # Handle each client connection in a separate thread
  Thread.new(client) do |c|
    # Receive the file size from the client
    file_size_str = c.gets.chomp
    file_size = file_size_str.to_i
    
    # Receive and save the file data
    begin
      file_path = "server_side/received_files/file_#{file_num}.txt"
      File.open(file_path, 'wb') do |file|
        bytes_received = 0
        while bytes_received < file_size
          chunk = c.read([1024, file_size - bytes_received].min)
          break if chunk.nil?  # Handle unexpected EOF or connection closure
          bytes_received += chunk.length
          file.write(chunk)
        end
      end
      
      # Send confirmation to client
      c.puts "File received and saved as file_#{file_num}.txt."
      
      file_num += 1
    rescue Errno::ENOENT => e
      # Send error to client
      c.puts "Error: #{e.message}"
    end
    
    # Close the connection to the client
    puts "Client disconnected"
    c.close
  end
end
