require 'open-uri'
require 'json'
require 'net/http'
require 'nokogiri'

def get_status(input)
  if input.match(/open/)
    :open
  elsif input.match(/close/)
    :closed
  end
end

def log(output)
  puts Time.now.strftime("%x %X: #{output.to_s}")
end

def find_time(input)
  match = input.match(/since (.*)/)
  if match
    Time.strptime(match[1], "%H:%M:%S %Y-%m-%d")
  else
    Time.now
  end
end

# Setup network stuff and base message
uri = URI.parse("https://hooks.slack.com/services/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")
req = Net::HTTP::Post.new(uri)
message = {username: "Unallobot Jr.", channel: "#slack_dev", icon_url: "https://s3.amazonaws.com/cwjstatic/unallocated_icon.png"}

# Get previous and current status
previous_space_status_message = File.read("uas_status.log")
previous_space_status = get_status previous_space_status_message
previous_update_time = find_time(previous_space_status_message).strftime("%s")
current_space_status_message = open("https://www.unallocatedspace.org/status").read
current_space_status = get_status current_space_status_message

if current_space_status != previous_space_status then
  File.write("uas_status.log", current_space_status_message)
  if current_space_status  == :open
    page = Nokogiri::HTML(open("http://unallocatedspace.org/thewall/all.php"))
    img_src = "http://unallocatedspace.org/thewall/" +  page.at_css("#galleryList li a").attr("href")
    attachments = {fallback: "UAS is open", ts: previous_update_time, text: "The space is open. <#{img_src}|See the 'Wall of Requests'>", color: "good"}
    message = message.merge({ attachments: [attachments]})
  else
    attachments = {fallback: "UAS is closed", ts: previous_update_time, text: "The space is closed", color: "danger"}
    message = message.merge({attachments: [attachments]})
  end
  req.body = JSON.generate(message)
  Net::HTTP.post_form(uri, payload: JSON.generate(message))
  log("message: #{JSON.generate(message)}")
end
