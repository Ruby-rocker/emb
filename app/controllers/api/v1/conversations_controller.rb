class Api::V1::ConversationsController < Api::V1::BaseController

  before_filter :auth_only!

  def index
    if params[:ids]
      conversations = current_user.conversations.find(params[:ids])
      render json: conversations

    elsif params[:search]
      user_ids = User.simple_search(params[:search]).map(&:id)
      user_ids.delete(current_user.id)

      conversations = current_user.conversations
          .joins(:users)
          .where{users.id.in my{user_ids}}

      render json: conversations

    elsif params[:recipient_ids]
      users = [User.find(params[:recipient_ids])] + [current_user]
      conversation = Conversation.for_users(users)
      conversation = conversation ? [conversation] : []
      render json: conversation

    else
      process_params

      conversations = current_user.conversations.with_read_marks_for(current_user)
      if @direction == 'earlier'
        conversations = conversations.where{updated_at.lt my{@timestamp}}
      elsif @direction == 'later' && @timestamp
        conversations = conversations.where{updated_at.gt my{@timestamp}}
      end
      conversations = conversations.order('conversations.updated_at DESC')
      conversations = conversations.limit(@limit) if @limit

      earliest_date = current_user.conversations
          .order('conversations.updated_at ASC')
          .limit(1)
          .pluck(:updated_at).first

      meta = { earliest_date: earliest_date }

      render json: conversations, meta: meta
    end
  end

  def show
    conversation = current_user.conversations.find(params[:id])
    render json: conversation
  end

  def update
    # mark as read/unread
    conversation = current_user.conversations.find(params[:id])
    if conversation.unread?(current_user)
      conversation.mark_as_read! for: current_user
      conversation.messages.mark_as_read! :all, for: current_user
    end
    render json: conversation
  end

  protected

    def process_params
      @timestamp = Time.zone.parse(params[:timestamp]) if params[:timestamp]

      unless params[:limit] == 'all'
        @limit = params[:limit].present? ? params[:limit].to_i : 10
      end

      if params[:direction].in? ['earlier', 'later']
        @direction = params[:direction]
      elsif @timestamp && !@limit
        @direction = 'later'
      end
    end

end
