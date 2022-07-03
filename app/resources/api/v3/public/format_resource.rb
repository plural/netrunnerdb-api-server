module API
  module V3
    module Public
      class Api::V3::Public::FormatResource < JSONAPI::Resource
        immutable
        
        attributes :name, :active_snapshot_id, :updated_at
        key_type :string

        paginator :none

        has_many :snapshots
        has_many :card_pools
      end
    end
  end
end