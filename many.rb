#!/usr/bin/env ruby

require 'socket'
require 'opencv'
include OpenCV

IMAGESNAP   = 'vendor/imagesnap/imagesnap_lorenz'
CASCADE     = './data/haarcascades/haarcascade_frontalface_alt.xml'
SOCKET_PATH = 'tmp/sock'
detector    = CvHaarClassifierCascade::load(CASCADE)

#image_data  = `#{IMAGESNAP} -t 0.2 -`
#image       = CvMat.decode(image_data.bytes.to_a)
#detector.detect_objects(image).each do |region|
  #color = CvColor::Blue
  #image.rectangle! region.top_left, region.bottom_right, color: color
#end

#window = GUI::Window.new('Face detection')
#window.show(image)
#GUI::wait_key

fork do
  window = GUI::Window.new('Face detection')
  Socket.unix_server_loop(SOCKET_PATH) do |sock, client_addrinfo|
    puts "HI"
    #IO.copy_stream(sock, STDOUT)
    image       = CvMat.decode(sock.bytes.to_a)
    #detector.detect_objects(image).each do |region|
      #color = CvColor::Blue
      #image.rectangle! region.top_left, region.bottom_right, color: color
    #end

    window.show(image)
    GUI::wait_key
  end 
end

sleep 1

Socket.unix(SOCKET_PATH) do |sock|
  pid = spawn "#{IMAGESNAP} -",  out: sock
  #pid = spawn "#{IMAGESNAP} - -t 0.2",  out: sock
  Process.wait pid
end
