require 'prometheus/client'

module Puma
  module Kubernetes
    class Parser
      def initialize(clustered = false)
        register_default_kubernetes
        register_clustered_kubernetes if clustered
      end

      def parse(stats, labels = {})
        stats.each do |key, value|
          value.each { |s| parse(s, labels.merge(index: s['index'])) } if key == 'worker_status'
          parse(value, labels) if key == 'last_status'
          update_metric(key, value, labels)
        end
      end

      private

      def register_clustered_kubernetes
        registry.gauge(:puma_booted_workers, docstring: 'Number of booted workers').set(1)
        registry.gauge(:puma_old_workers, docstring: 'Number of old workers').set(0)
      end

      def register_default_kubernetes
        registry.gauge(:puma_backlog, docstring: 'Number of established but unaccepted connections in the backlog')
        registry.gauge(:puma_running, docstring: 'Number of running worker threads')
        registry.gauge(:puma_pool_capacity, docstring: 'Number of allocatable worker threads')
        registry.gauge(:puma_max_threads, docstring: 'Maximum number of worker threads')
        registry.gauge(:puma_workers, docstring: 'Number of configured workers').set(1)
        registry.gauge(:puma_usage, docstring: 'Result of (1 - puma_pool_capacity/puma_max_threads)')
      end

      def registry
        Prometheus::Client.registry
      end

      def update_metric(key, value, labels)
        return if registry.get("puma_#{key}").nil?

        registry.get("puma_#{key}").set(value, labels)
      end
    end
  end
end
