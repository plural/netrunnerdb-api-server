# frozen_string_literal: true

# Controller for the PublishedDatabase resource.
class PublishedDatabasesController < ApplicationController
  def index
    add_total_stat(params)
    published_databases = PublishedDatabaseResource.all(params)
    respond_with(published_databases)
  end

  def add_total_stat(params)
    # don't return stats
  end
end
