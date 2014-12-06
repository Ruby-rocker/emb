class Api::V1::MessagesController < Api::V1::BaseController

  before_filter :auth_only!

  def index
    if params[:ids]
      conversation_ids = current_user.conversations.pluck(:id)
      messages = Message.where{conversation_id.in conversation_ids}.find(params[:ids])
      render json: messages
    else
      process_params

      messages = @conversation.messages
      if @direction == 'earlier'
        messages = messages.where{created_at.lt my{@timestamp}}
      elsif @direction == 'later'
        messages = messages.where{created_at.gt my{@timestamp}}
      end
      messages = messages.order('created_at DESC')
      messages = messages.limit(@limit) if @limit

      render json: messages
    end
  end

  def show
    conversation_ids = current_user.conversations.pluck(:id)
    message = Message.where{conversation_id.in conversation_ids}.find(params[:id])
    render json: message
  end

  def create
    conversation_id = params[:message].delete(:conversation_id)
    recipient_ids = params[:message].delete(:recipient_ids)

    # check for existing conversation between specified users
    conversation = find_or_initialize_conversation(conversation_id, recipient_ids)

    # we don't want to allow setting read/unread during creation
    params[:message].delete(:unread)

    message = conversation.messages.new(params[:message])
    message.user = current_user

    if conversation.save
      # send e-mail notifications
      recipients = conversation.users.all - [current_user]
      recipients.each do |recipient|
        UserMailer.delay.new_message(recipient.id, message.id) if recipient.email_on_message
      end
      render json: message, serializer: MessageWithConversationSerializer, status: 201
    else
      warden.custom_failure!
      render json: message, status: 422
    end
  end

  protected

    def process_params
      @conversation = current_user.conversations.find(params[:conversation_id])
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

    def find_or_initialize_conversation(id, recipient_ids)
      if id
        current_user.conversations.find(id)
      else
        find_conversation(recipient_ids) || new_conversation(recipient_ids)
      end
    end

    def find_conversation(recipient_ids)
      users = User.find(recipient_ids)
      if users.any?
        users = users + [current_user]
        Conversation.for_users(users)
      end
    end

    def new_conversation(recipient_ids)
      users = current_user.friends.find(recipient_ids) # only friends
      conversation = Conversation.new
      conversation.users << current_user
      conversation.users << users
      return conversation
    end

end
