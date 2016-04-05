module Kubeformation
  class Tokens < Common
    TOKENS = %w(
      KUBE_USER
      KUBE_PASSWORD
      KUBE_BEARER_TOKEN
      KUBELET_TOKEN
      KUBE_PROXY_TOKEN
    )

    def generate
      @logger.info 'Generating tokens...'
      ENV['KUBE_TEMP'] =  @options[:destination]
      ENV['MASTER_NAME'] = @options[:master_name]
      ENV['SERVICE_CLUSTER_IP_RANGE'] = @options[:service_cluster_ip_range]
      ENV['DNS_DOMAIN'] = @options[:dns_domain]

      Dir.mktmpdir do |dir|
        ENV['KUBE_TEMP'] = dir

        command = [
          "source #{@options[:source]}/cluster/common.sh",
          'gen-kube-basicauth',
          'gen-kube-bearertoken',
          "source #{@options[:source]}/cluster/aws/util.sh",
          'get-tokens',
          "( #{echo_tokens} ) > #{@options[:destination]}/tokens.sh"
        ].join(';')

        %x( bash -c '#{command}' )
      end
    end

    private

    def echo_tokens
      TOKENS.map { |token| format_token token }.join(';')
    end

    def format_token token
      "echo declare -rx #{token}=$#{token}"
    end
  end
end
