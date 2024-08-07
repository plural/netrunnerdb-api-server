# frozen_string_literal: true

require 'English'
require 'jwt'

# Inspects the HTTP Authorization header for a Bearer JWT token and
# populates the @auth_token_payload instance variable with the JWT payload.
# This does no signature verification of the JWT, expecting a gateway or
# proxy to have done that already.
# If the payload cannot be parsed or does not have a preferred_username
# attribute, a 401 Unauthorized response with an empty JSON body will be
# returned.
# All private API endpoints should include this concern and can rely on the
# preferred_username to represent the user.
module JwtAuthorizationConcern
  extend ActiveSupport::Concern

  def current_user
    @current_user
  end

  included do
    before_action :check_token
  end

  private

  def check_token
    @auth_token_payload = nil
    @current_user = nil

    jwt = nil

    auth_header = request.headers['Authorization']
    unless auth_header.nil?
      m = auth_header.match(/^Bearer (.*)$/)
      if m && m.captures.length == 1
        # TODO(plural): Update this to validate the JWT more when we settle on an ID provider & API gateway.
        begin
          decoded_token = JWT.decode m.captures[0], nil, false
          if decoded_token[0].key?('preferred_username')
            jwt = decoded_token[0]
            get_or_insert_user(jwt['preferred_username'])
          end
        rescue JWT::DecodeError
          Rails.logger.error "JWT decode error: #{$ERROR_INFO}"
        end
      end
    end
    raise ApplicationController::UnauthenticatedError if jwt.nil?

    @auth_token_payload = jwt
  end

  def get_or_insert_user(username)
    user = nil
    begin
      user = User.find(username)
    rescue ActiveRecord::RecordNotFound
      user = User.new
      user.id = username
      user.save
    end
    @current_user = user
  end
end
