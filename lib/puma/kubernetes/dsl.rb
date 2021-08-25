module Puma
  class DSL
    def kubernetes_url(url)
      @options[:kubernetes_url] = url
    end
    def kubernetes_stats_hook(&block)
      @options[:kubernetes_stats_hook] = block
    end
  end
end
