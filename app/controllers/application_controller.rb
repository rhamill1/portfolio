class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  config.action_dispatch.default_headers = {
    'X-Frame-Options' => 'ALLOWALL'
  }
end
