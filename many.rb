#!/usr/bin/env ruby

#./many.rb | ffmpeg  -y -f mjpeg -r 5 -i - -an output.avi

require 'socket'
require 'opencv'
include OpenCV

#IMAGESNAP   = 'vendor/imagesnap/imagesnap_lorenz'
IMAGESNAP   = 'vendor/imagesnap/imagesnap_lorenz_stream'
CASCADE     = './data/haarcascades/haarcascade_frontalface_alt.xml'
SOCKET_PATH = 'tmp/sock'
detector    = CvHaarClassifierCascade::load(CASCADE)

fork do
  Socket.unix_server_loop(SOCKET_PATH) do |sock, client_addrinfo|
    sock.lines('vvvvv') do |sock|
      image = CvMat.decode(sock.gsub(/vvvvv/, '').bytes.to_a)
      detector.detect_objects(image).each do |region|
        color = CvColor::Blue
        image.rectangle! region.top_left, region.bottom_right, color: color
      end
      #puts image.methods.sort
      #File.binwrite('mark.jpg', image.data)
      #puts image.encode('.jpg')
      #image.save_image('ex.jpg')
      #IO.copy_stream image.data, STDOUT
    end
  end 
end

sleep 1

Socket.unix(SOCKET_PATH) do |sock|
  pid = spawn "#{IMAGESNAP} - -t 0.2",  out: sock
  Process.wait pid
end
