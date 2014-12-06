class Api::V1::NotificationCountsController < Api::V1::BaseController

  before_filter :auth_only!

  def show
    unread_conversations = current_user.conversations
        .unread_by(current_user).count

    unread_notifications = current_user.notification_activities
        .unread.joins(:activity).count

    pending_received_friendships = current_user.pending_received_friendships.count

    pending_invitations = current_user.event_invitations.pending.count

    json = {
      notification_count: {
        id: params[:id],
        user_id: current_user.id,
        unread_conversations: unread_conversations,
        unread_notifications: unread_notifications,
        pending_received_friendships: pending_received_friendships,
        pending_invitations: pending_invitations
      }
    }

    render json: json
  end

end
