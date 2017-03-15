require 'open-uri'
require 'json'
require 'net/http'
require 'nokogiri'

uri = URI.parse("https://hooks.slack.com/services/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")
req = Net::HTTP::Post.new(uri)
current_space_status = open("http://www.unallocatedspace.org/status").read
previous_space_status = File.read("uas_status.log")
message = {username: "Unallobot", channel: "#slack_dev", icon_url: "https://s3.amazonaws.com/cwjstatic/unallocated_icon.png"}
puts DateTime.now.strftime("%Y-%m-%d %H%M: ") + "prev stats: #{previous_space_status}, cur stats: #{current_space_status}"
if current_space_status != previous_space_status then
  File.write("uas_status.log", current_space_status)
  if current_space_status.include? "open"
    page = Nokogiri::HTML(open("http://unallocatedspace.org/thewall/all.php"))
    img_src = "http://unallocatedspace.org/thewall/" +  page.at_css("#galleryList li a").attr("href")
    attachments = {text: "The space is open", image_url: img_src, color: "good"}
    message = message.merge({fallback: "UAS is open", attachments: [attachments]})
  else
    attachments = {text: "The space is closed", color: "danger"}
    message = message.merge({fallback: "UAS is closed", attachments: [attachments]})
  end
  req.body = JSON.generate(message)
  res = Net::HTTP.post_form(uri, payload: JSON.generate(message))
  puts message
  puts res.message
  puts res.body
end
