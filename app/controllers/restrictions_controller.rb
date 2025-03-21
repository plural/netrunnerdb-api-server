# frozen_string_literal: true

# Controller for the Restriction resource.
class RestrictionsController < ApplicationController
  def index
    add_total_stat(params)
    restrictions = RestrictionResource.all(params)

    respond_with(restrictions)
  end

  def show
    restriction = RestrictionResource.find(params)
    respond_with(restriction)
  end
end
