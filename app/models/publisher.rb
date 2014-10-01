module Citygram::Models
  class Publisher < Sequel::Model
    one_to_many :subscriptions
    one_to_many :events

    plugin :url_validation

    dataset_module do
      def visible
        where(visible: true)
      end

      def active
        where(active: true)
      end
    end

    def validate
      super
      validates_presence [:title, :endpoint, :city, :icon]
      validates_url :endpoint
      validates_unique :title
      validates_unique :endpoint
    end
  end
end
