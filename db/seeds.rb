require 'rest_client'
require 'fastimage'
require 'json'

fp_api_key = Rails.application.config.filepicker_rails.api_key
fp_upload_url = "https://www.filepicker.io/api/store/S3?key=#{fp_api_key}"

admin_user = User.admin.first

if !admin_user && Rails.env.production?
  raise "Create an admin user before running this in production!"
end

if !admin_user && !Rails.env.production?
  print "No admin user found, creating... "
  user = create_user(0)
  user.update_attribute(:is_admin, true)
  puts "done: #{user.email}/password"
  admin_user = user
end

Dir[Rails.root.join("db/seeds/cover_photos", "*.{jpg,jpeg,png}")].each do |image_path|
  filename = File.basename(image_path)

  unless Attachment.exists?(filename: filename, sub_type: 'yostalgia_cover')
    print "Uploading cover photo '#{filename}' ... "
    image_file = File.new(image_path)

    width, height = FastImage.size(image_path)

    response = RestClient.post fp_upload_url, fileUpload: image_file
    result = JSON.parse(response.to_s)

    attachment = Attachment.new
    attachment.user = admin_user
    attachment.sub_type = 'yostalgia_cover'

    attachment.url = result['url']
    attachment.s3_key = result['key']
    attachment.filename = result['filename']
    attachment.mimetype = result['type']
    attachment.filesize = result['size'].to_i
    attachment.width = width
    attachment.height = height

    if attachment.save
      puts 'done'
    else
      puts "error: #{attachment.errors.full_messages.to_sentence}"
    end
  end
end

Profile.where(cover_photo_id: nil).each do |profile|
  attachment_id = Attachment.yostalgia_cover.order("RANDOM()").first.id
  profile.update_attribute :cover_photo_id, attachment_id
end
