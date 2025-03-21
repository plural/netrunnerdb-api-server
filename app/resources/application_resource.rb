# frozen_string_literal: true

# ApplicationResource is similar to ApplicationRecord - a base class that
# holds configuration/methods for subclasses.
# All Resources should inherit from ApplicationResource.
class ApplicationResource < Graphiti::Resource
  # Use the ActiveRecord Adapter for all subclasses.
  # Subclasses can still override this default.
  self.abstract_class = true
  self.adapter = Graphiti::Adapters::ActiveRecord
  self.base_url = Rails.application.routes.default_url_options[:host]
  # Default to the public endpoint namespace.
  self.endpoint_namespace = '/api/v3/public'
  self.autolink = true
  link(:self) { |resource| "#{endpoint[:url]}/#{resource.id}" } if endpoint[:actions].include?(:show)
  # Cache things for a week. Cache keys will update when entities are updated.
  self.cache_resource expires_in: 1.week # rubocop:disable Style/RedundantSelf
end
