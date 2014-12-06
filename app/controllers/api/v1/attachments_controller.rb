class Api::V1::AttachmentsController < Api::V1::BaseController

  before_filter :auth_only!
  before_filter :find_attachable, only: :create

  def index
    if params[:ids]
      find_by_ids
    elsif params[:profile_photos] == 'true'
      find_profile_photos
    elsif params[:cover_photos] == 'true'
      find_cover_photos
    elsif params[:yostalgia_covers] == 'true'
      find_yostalgia_cover_photos
    else
      find_general_photos
    end
  end

  def show
    attachment = Attachment.where{(attachable_type == 'Profile') | (user_id.in my{valid_user_ids})}.find(params[:id])
    respond_with attachment
  end

  def create
    return unauthorized if @attachable.user != current_user

    params[:attachment].delete(:user_id)

    attachment = Attachment.new(params[:attachment])
    attachment.attachable = @attachable
    attachment.user = current_user
    if attachment.save
      render json: attachment, status: 201
    else
      render json: attachment, status: 422
    end
  end

  protected

    def find_by_ids
      ids = params[:ids]
      attachments = Attachment.where{(attachable_type == 'Profile') | ((id.in ids) & (user_id.in my{valid_user_ids}))}
      render json: attachments
    end

    def find_general_photos
      user = get_user
      page = params[:page].present? ? params[:page].to_i : 1
      limit = params[:limit].present? ? params[:limit].to_i : 20
      attachments = user.attachments.general.order('created_at DESC').page(page).per(limit)
      totals = total_metadata(user)
      more_pages = totals[:total_photos] - page * limit > 0 ? 'yes' : 'no'
      meta = { page: page, more_pages: more_pages }
      render json: attachments, each_serializer: AttachmentLightSerializer, meta: meta.merge(totals)
    end

    def find_profile_photos
      user = get_user
      page = params[:page].present? ? params[:page].to_i : 1
      limit = params[:limit].present? ? params[:limit].to_i : 20
      attachments = user.attachments.profile.order('created_at DESC').page(page).per(limit)
      totals = total_metadata(user)
      more_pages = totals[:total_profile_photos] - page * limit > 0 ? 'yes' : 'no'
      meta = { page: page, more_pages: more_pages }
      render json: attachments, each_serializer: AttachmentLightSerializer, meta: meta.merge(totals)
    end

    def find_cover_photos
      user = get_user
      page = params[:page].present? ? params[:page].to_i : 1
      limit = params[:limit].present? ? params[:limit].to_i : 20
      attachments = user.attachments.cover.order('created_at DESC').page(page).per(limit)
      totals = total_metadata(user)
      more_pages = totals[:total_cover_photos] - page * limit > 0 ? 'yes' : 'no'
      meta = { page: page, more_pages: more_pages }
      render json: attachments, each_serializer: AttachmentLightSerializer, meta: meta.merge(totals)
    end

    def find_yostalgia_cover_photos
      attachments = Attachment.yostalgia_cover
      meta = { page: 1, more_pages: 'no' }
      render json: attachments, each_serializer: AttachmentLightSerializer, meta: meta
    end

    def get_user
      User.where{id.in my{valid_user_ids}}.find(params[:user_id])
    end

    def total_metadata(user)
      {
        total_photos: user.attachments.general.count,
        total_profile_photos: user.attachments.profile.count,
        total_cover_photos: user.attachments.cover.count
      }
    end

    def find_attachable
      type = params[:attachment].delete(:attachable_type)
      id = params[:attachment].delete(:attachable_id)
      @attachable = type.singularize.classify.constantize.find(id)
    end

end
