#!/usr/bin/env ruby

require 'opencv'
include OpenCV

IMAGESNAP = 'vendor/imagesnap/imagesnap'
CASCADE   = './data/haarcascades/haarcascade_frontalface_alt.xml'
detector  = CvHaarClassifierCascade::load(CASCADE)

image_data  = `#{IMAGESNAP} -`
image       = CvMat.decode(image_data.bytes.to_a)
detector.detect_objects(image).each do |region|
  color = CvColor::Blue
  image.rectangle! region.top_left, region.bottom_right, color: color
end

window = GUI::Window.new('Face detection')
window.show(image)
GUI::wait_key
