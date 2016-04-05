module Kubeformation
  class Certificates < Common
    FILES = %w(
      CA_CERT_BASE64
      MASTER_CERT_BASE64
      MASTER_KEY_BASE64
      KUBELET_CERT_BASE64
      KUBELET_KEY_BASE64
      KUBECFG_CERT_BASE64
      KUBECFG_KEY_BASE64
    )

    def generate
      @logger.info 'Generating certificates...'
      ENV['KUBE_TEMP'] =  @options[:destination]
      ENV['MASTER_NAME'] = @options[:master_name]
      ENV['SERVICE_CLUSTER_IP_RANGE'] = @options[:service_cluster_ip_range]
      ENV['DNS_DOMAIN'] = @options[:dns_domain]

      Dir.mktmpdir do |dir|
        ENV['KUBE_TEMP'] = dir

        command = [
          "source #{@options[:source]}/cluster/common.sh",
          "create-certs #{@options[:master_ip]}",
          echo_files
        ].join(';')

        %x( bash -c '#{command}' )
      end
    end

    private

    def echo_files
      FILES.map do |file|
        filename = file.downcase
        suffix = determine_suffix filename

        "echo $#{file} > #{@options[:destination]}/#{filename}.#{suffix}"
      end.join(';')
    end

    def determine_suffix string
      case string
      when /^ca/
        'ca'
      when /_cert_/
        'cert'
      when /_key_/
        'key'
      else
        fail('Invalid suffix detected.')
      end
    end
  end
end


