require 'base64'

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
          "create-certs #{@options[:master_internal_ip]}",
          echo_files
        ].join(';')

        %x( bash -c '#{command}' )


        %x( bash -c '( #{echo_certificates} ) > #{@options[:destination]}/certificates.sh' )
      end
    end

    private

    def echo_files
      FILES.map do |file|
        filename = convert_filename file

        case RUBY_PLATFORM
        when /darwin/
          base64_option = '-D'
        else
          base64_option = '-d'
        end

        "echo $#{file} | base64 #{base64_option} > #{@options[:destination]}/#{filename}"
      end.join(';')
    end

    def echo_certificates
      FILES.map do |file|
        filename = convert_filename file

        contents = File.read "#{@options[:destination]}/#{filename}"
        contents_base64 = Base64.strict_encode64 contents

        variable = file.gsub(/_BASE64/, '')

        "echo declare -rx #{variable}=#{contents_base64}"
      end.join(';')
    end

    def convert_filename filename
      filename
        .downcase             # lowercase
        .gsub(/_base64/, '')  # remove _base64
        .gsub(/_/, '.')       # replace underscore with fullstop
    end
  end
end
