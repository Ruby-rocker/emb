class Api::V1::EventInvitationsController < Api::V1::BaseController

  before_filter :auth_only!
  before_filter :clean_up_params, only: [:create, :update]

  def index
    if params[:ids]
      find_by_ids
    elsif params[:event_id] && params[:user_id]
      find_by_event_and_user
    elsif params[:event_id]
      find_by_event_id
    elsif params[:pending]
      invitations = current_user.event_invitations.pending
      render json: invitations
    end
  end

  def show
    invitation = EventInvitation.where{(event_id.in my{invited_event_ids})}.find(params[:id])
    respond_with invitation
  end

  def create
    params[:event_invitation].delete(:acceptance_confirmed_at)
    event = current_user.events.find(params[:event_invitation].delete(:event_id))
    invitation = event.event_invitations.build(params[:event_invitation])

    if invitation.save
      if invitation.user.email_on_event_invite
        UserMailer.delay.new_event_invite(invitation.id)
      end

      render json: invitation, status: 201
    else
      render json: invitation, status: 422
    end
  end

  def update
    acceptance_confirmed_at = DateTime.parse(params[:event_invitation][:acceptance_confirmed_at])
    if !DateTime.now.between?(acceptance_confirmed_at - 5.minutes, acceptance_confirmed_at + 5.minutes)
      render(json: { errors: 'acceptance_confirmed_at out of valid range' }, status: 422) and return
    end

    invitation = current_user.event_invitations.find(params[:id])

    if invitation.update_attributes(params[:event_invitation])
      if invitation.accepted?
        invitation.create_activity key: 'event_invitation.accept'
      else
        invitation.create_activity key: 'event_invitation.decline'
      end
      render json: invitation
    else
      render json: invitation, status: 422
    end
  end

  def destroy
    user_event_ids = current_user.events.pluck(:id)
    invite = EventInvitation.where{(id.in my{user_event_ids})}.find(params[:id])

    if invite.destroy
      render json: invite
    else
      render json: invite, status: 422
    end
  end

  protected

    def clean_up_params
      params[:event_invitation].delete(:created_at)
    end

    def find_by_ids
      invitations = EventInvitation.where{
        (event_id.in my{vinvited_event_ids})
      }.find(params[:ids])
      respond_with invitations
    end

    def find_by_event_id
      invitation = EventInvitation.where{
        (event_id.in my{invited_event_ids}) &
        (event_id == my{params[:event_id]})
      }
      respond_with invitation
    end

    def find_by_event_and_user
      invitation = EventInvitation.where{
        (event_id.in my{invited_event_ids}) &
        (event_id == my{params[:event_id]}) &
        (user_id == my{params[:user_id]})
      }.first
      respond_with invitation
    end

end
