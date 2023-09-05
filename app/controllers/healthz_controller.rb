class HealthzController < ApplicationController

  # GET /healthz
  def healthz
    render json: {
      status: 'OK',
      commit: (ENV.fetch('COMMIT_HASH', nil) || ENV.fetch('RENDER_GIT_COMMIT', nil)).to_s,
      branch: (ENV.fetch('COMMIT_HASH', nil) || ENV.fetch('RENDER_GIT_BRANCH', nil)).to_s
    }
  end

end
