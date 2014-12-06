namespace :activities do
  desc "populate empty activity log from existing posts/events/comments"
  task populate_empty_log: :environment do
    Post.all.map{|post| post.create_activity(:create) }
    Event.all.map{|event| event.create_activity(:create) }
    Comment.all.map{|comment| comment.create_activity(:create) }
  end
end
