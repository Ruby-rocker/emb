class Api::StaticController < ApplicationController

  def error404
    render nothing: true, status: 404
  end

end
