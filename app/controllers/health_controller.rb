class HealthController < ActionController::Base
  def show
    render plain: "Bloom is healthy", status: :ok
  end
end
