class HealthzController < ApplicationController

  # GET /healthz
  def healthz
    render json: {
      status: 'OK',
      commit: ENV.fetch('COMMIT_HASH', nil).to_s
    }
  end

end
