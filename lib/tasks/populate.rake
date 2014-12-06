require 'ffaker'
require 'populator'
require 'progress_bar'

USER_COUNT = 100
POST_COUNT = 1500
EVENTS_COUNT = 50

namespace :db do
  namespace :populate do
    desc "Populate database with random data (best to run `rake db:reset` first)"
    task all: :environment do
      disable_emails # disable sending of e-mails when publishing activities

      Rake::Task["db:populate:users"].invoke
      Rake::Task["db:populate:friend_graph"].invoke
      Rake::Task["db:populate:posts"].invoke
      Rake::Task["db:populate:events"].invoke
      Rake::Task["db:populate:likes"].invoke
      Rake::Task["db:populate:comments"].invoke
      Rake::Task["db:populate:conversations"].invoke
    end

    desc "Populate DB with 100 random users"
    task users: :environment do
      disable_emails # disable sending of e-mails when publishing activities

      puts 'Creating 100 users... '
      bar = ProgressBar.new(USER_COUNT)

      USER_COUNT.times do |i|
        create_user(i)
        bar.increment!
      end
    end

    desc "Creates friendships between existing users"
    task friend_graph: :environment do
      disable_emails # disable sending of e-mails when publishing activities

      puts 'Populating social graph...'
      bar = ProgressBar.new(User.count)

      all_user_ids = User.confirmed.pluck(:id)
      all_user_ids.each do |user_id|
        populate_friend_graph_for(user_id, all_user_ids)
        bar.increment!
      end
    end

    desc "Creates random posts over the last 6 months"
    task posts: :environment do
      disable_emails # disable sending of e-mails when publishing activities

      puts 'Populating posts (this will take a while)...'
      bar = ProgressBar.new(POST_COUNT)

      user_ids = User.confirmed.pluck(:id)

      POST_COUNT.times do
        user = User.find(user_ids.sample)
        friend_ids = user.friend_ids
        r = rand(100)

        if r < 60 # 60% text posts
          create_text_post(user, friend_ids)
        elsif r < 85 # 25% single image posts
          create_image_post(user, friend_ids)
        else # 15% gallery posts
          create_gallery_post(user, friend_ids)
        end

        bar.increment!
      end
    end

    desc "Creates random events with posts over the last 6 months"
    task events: :environment do
      disable_emails # disable sending of e-mails when publishing activities

      puts 'Populating events... (this will take a while)'
      bar = ProgressBar.new(EVENTS_COUNT)

      user_ids = User.confirmed.pluck(:id)

      EVENTS_COUNT.times do
        user = User.find(user_ids.sample)
        friend_ids = user.friend_ids

        event = create_event(user, friend_ids)
        create_event_invites(event, friend_ids)
        create_event_posts(event)

        bar.increment!
      end
    end

    desc "Creates random likes on each post/attachment"
    task likes: :environment do
      disable_emails # disable sending of e-mails when publishing activities

      puts 'Liking posts...'
      bar = ProgressBar.new(Post.count)
      Post.pluck(:id).each do |post_id|
        if rand(100) < 60
          post = Post.find(post_id)
          generate_likes_for(post)
        end
        bar.increment!
      end

      puts 'Liking attachments...'
      bar = ProgressBar.new(Attachment.count)
      Attachment.pluck(:id).each do |attachment_id|
        if rand(100) < 60
          attachment = Attachment.find(attachment_id)
          generate_likes_for(attachment)
        end
        bar.increment!
      end
    end

    desc "Creates random comments on each post/attachment"
    task comments: :environment do
      disable_emails # disable sending of e-mails when publishing activities

      puts 'Commenting posts...'
      bar = ProgressBar.new(Post.count)
      Post.pluck(:id).each do |post_id|
        if rand(100) < 60
          post = Post.find(post_id)
          generate_comments_for(post)
        end
        bar.increment!
      end

      puts 'Commenting attachments...'
      bar = ProgressBar.new(Attachment.count)
      Attachment.pluck(:id).each do |attachment_id|
        if rand(100) < 60
          attachment = Attachment.find(attachment_id)
          generate_comments_for(attachment)
        end
        bar.increment!
      end
    end

    desc "Creates random conversations between friends"
    task conversations: :environment do
      puts 'Creating conversations...'
      bar = ProgressBar.new(User.count)
      User.confirmed.pluck(:id).each do |user_id|
        user = User.find(user_id)
        friend_ids = user.friend_ids
        (rand(20)+1).times do
          if rand(100) < 80
            # single recipient conversation
            recipient_id = friend_ids.sample
            conversation = find_or_initialize_conversation(user, [recipient_id])
            (rand(20)+1).times do
              add_message_to_conversation(user, conversation)
            end
            conversation.save
          else
            # multiple recipient conversation
            recipient_ids = friend_ids.sample(rand(4)+1)
            conversation = find_or_initialize_conversation(user, recipient_ids)
            (rand(20)+1).times do
              add_message_to_conversation(user, conversation)
            end
            conversation.save
          end
        end
        bar.increment!
      end
    end


    ### User methods ###########################################################

    def create_user(i = nil)
      i = rand(100) if i.nil?
      signup = Signup.new
      signup.gender = ['Male', 'Female'].sample
      if signup.gender == 'Male'
        signup.first_name = Forgery(:name).male_first_name
      else
        signup.first_name = Forgery(:name).female_first_name
      end
      signup.last_name = Forgery(:name).last_name
      signup.username = signup.full_name.parameterize('_')
      signup.username += "#{i}" if i
      signup.email = "#{signup.username}@example.com"
      signup.password = "password"
      signup.birthday = time_rand(110.years.ago, 1.year.ago).to_date
      signup.about_me = Faker::HipsterIpsum.sentences((1..5).to_a.sample).join(' ')
      signup.location = "#{Faker::AddressUS.city}, #{Faker::AddressUS.state}"
      signup.education = Faker::Education.school
      signup.occupation = Faker::Job.title

      image_id = i > 50 ? i-50 : i
      image_gender = signup.gender == 'Male' ? 'men' : 'women'
      image_url = "http://api.randomuser.me/0.3.2/portraits/#{image_gender}/#{image_id}.jpg"
      signup.image_url = image_url

      signup.skip_confirmation!
      signup.skip_email_validation!
      if signup.save
        user = signup.user
        user.email_on_friend_request = false
        user.email_on_comment = false
        user.email_on_like = false
        user.email_on_event_invite = false
        user.email_on_event_post = false
        user.email_on_message = false
        user.email_on_mention = false
        user.email_on_tag = false
        user.save
        return user
      else
        abort "Error creating user: #{signup.errors.full_messages.to_sentence}"
      end
    end


    ### Social Graph methods ###################################################

    def populate_friend_graph_for(user_id, all_user_ids)
      user = User.find(user_id)
      existing_friend_ids = user.friend_ids + user.friend_ids(include_pending: true)
      new_friend_ids = all_user_ids.sample(rand(USER_COUNT/4)) - [user.id] - existing_friend_ids
      new_pending_friend_ids = all_user_ids.sample(rand(3)) - [user.id] - existing_friend_ids - new_friend_ids

      i = 0
      Friendship.populate(new_friend_ids.size) do |friendship|
        friendship.sender_id = user.id
        friendship.receiver_id = new_friend_ids[i]
        friendship.pending = false
        i = i+1
      end

      i = 0
      Friendship.populate(new_pending_friend_ids.size) do |friendship|
        friendship.sender_id = user.id
        friendship.receiver_id = new_pending_friend_ids[i]
        friendship.pending = true
        i = i+1
      end
    end


    ### Post methods ##########################################################

    def create_text_post(user, friend_ids, event_id = nil)
      post = user.posts.new
      post.posted_at = time_rand 6.months.ago
      post.created_at = post.posted_at
      post.event_id = event_id if event_id
      post.is_private = rand(100) < 10
      if rand(100) < 50
        post.title = Faker::HipsterIpsum.words(rand(5)+1).join(' ')
      end
      if rand(100) < 25
        post.tagged_users << User.find(friend_ids.sample(rand(5)))
      end
      post.body = generate_post_body(friend_ids)
      post.save
    end

    def create_image_post(user, friend_ids, event_id = nil)
      post = user.posts.new
      post.posted_at = time_rand 6.months.ago
      post.created_at = post.posted_at
      post.event_id = event_id if event_id
      post.is_private = rand(100) < 10
      if rand(100) < 50
        post.title = Faker::HipsterIpsum.words(rand(5)+1).join(' ')
      end
      if rand(100) < 25
        post.body = generate_post_body(friend_ids)
      end
      if rand(100) < 25
        post.tagged_users << User.find(friend_ids.sample(rand(5)))
      end
      attachment = generate_attachment(user)
      post.attachments << attachment
      post.save
    end

    def create_gallery_post(user, friend_ids, event_id = nil)
      post = user.posts.new
      post.posted_at = time_rand 6.months.ago
      post.created_at = post.posted_at
      post.event_id = event_id if event_id
      post.is_private = rand(100) < 10
      if rand(100) < 50
        post.title = Faker::HipsterIpsum.words(rand(5)+1).join(' ')
      end
      if rand(100) < 25
        post.body = generate_post_body(friend_ids)
      end
      if rand(100) < 25
        post.tagged_users << User.find(friend_ids.sample(rand(5)))
      end
      rand(10).times do |i|
        attachment = generate_attachment(user)
        post.attachments << attachment
      end
      post.save
    end


    ### Event methods ##########################################################

    def create_event(user, friend_ids)
      event = user.events.new
      event.is_private = rand(100) < 10
      event.title = Faker::HipsterIpsum.words(rand(6)+1).join(' ')
      event.body = generate_post_body(friend_ids)
      event.start_time = time_rand(6.months.ago)
      event.end_time = event.start_time + (rand(48)+1).hours
      event.location = "#{Faker::AddressUS.city}, #{Faker::AddressUS.state}"
      event.cover_photo = generate_attachment(user, for_event: true)
      event.created_at = time_rand(6.months.ago, event.start_time)
      event.save
      return event
    end

    def create_event_invites(event, friend_ids)
      invitee_ids = friend_ids.sample(rand(friend_ids.size))
      invitee_ids.each do |invitee_id|
        invitation = EventInvitation.new
        invitation.event_id = event.id
        invitation.user_id = invitee_id
        invitation.accepted = rand(100) < 80
        if invitation.accepted
          invitation.acceptance_confirmed_at = time_rand(6.months.ago, event.start_time)
        else
          invitation.accepted = false if rand(100) < 10
        end
        invitation.save

        if invitation.accepted?
          invitation.create_activity key: 'event_invitation.accept'
        else
          invitation.create_activity key: 'event_invitation.decline'
        end
      end
    end

    def create_event_posts(event)
      attendees = event.attendees + [event.user]
      attendee_ids = attendees.map(&:id)
      rand(15).times do
        r = rand(100)
        user = attendees.sample

        if r < 50 # 50% text posts
          create_text_post(user, attendee_ids, event.id)
        elsif r < 80 # 30% single image posts
          create_image_post(user, attendee_ids, event.id)
        else # 20% gallery posts
          create_gallery_post(user, attendee_ids, event.id)
        end
      end
    end


    ### Conversation methods ###################################################

    def find_or_initialize_conversation(user, recipient_ids)
      find_conversation(user, recipient_ids) || new_conversation(user, recipient_ids)
    end

    def find_conversation(user, recipient_ids)
      recipients = User.find(recipient_ids)
      if recipients.any?
        users = recipients + [user]
        Conversation.for_users(users)
      end
    end

    def new_conversation(user, recipient_ids)
      recipients = user.friends.find(recipient_ids) # only friends
      conversation = Conversation.new
      conversation.users << user
      conversation.users << recipients
      return conversation
    end

    def add_message_to_conversation(user, conversation)
      message = conversation.messages.new
      if conversation.messages.size == 1
        message.user = user
      else
        message.user = conversation.users.sample
      end
      if rand(100) < 20
        message.body = Faker::Lorem.paragraphs(rand(6)+1).join("\n\n")
      else
        message.body = Faker::Lorem.sentences(rand(6)+1).join(' ')
      end
    end


    ### General Methods ########################################################

    def disable_emails
      PublicActivity::Activity.publish_options[:send_emails] = false
    end

    def generate_attachment(user, options = {})
      width, height = rand(100) < 75 ? [1024,768] : [768,1024]
      attachment = Attachment.new_from_url("http://lorempixel.com/#{width}/#{height}", width, height)
      attachment.user = user
      attachment.sub_type = 'event_photo' if options[:for_event]
      attachment
    end

    def generate_post_body(friend_ids)
      body = Faker::HipsterIpsum.sentences(rand(5)+1).join(' ')
      if rand(100) < 20
        friend = User.find(friend_ids.sample)
        mention = "@[#{friend.profile.full_name}](User:#{friend.id}) "
        body.prepend mention
      end
      body
    end

    def generate_likes_for(likeable)
      friend_ids = likeable.user.friend_ids + [likeable.user.id]
      friend_ids.sample(rand(friend_ids.size)).each do |friend_id|
        like = likeable.likes.new
        like.user_id = friend_id
        like.emotion_cd = rand(6)+1
        like.save
      end
    end

    def generate_comments_for(commentable)
      friend_ids = commentable.user.friend_ids + [commentable.user_id]
      (rand(30)+1).times do
        comment = commentable.comments.new
        comment.user_id = friend_ids.sample
        comment.body = generate_post_body(friend_ids)
        comment.save
      end
    end

    def time_rand from = 0.0, to = Time.now
      Time.at(from + rand * (to.to_f - from.to_f))
    end
  end
end
