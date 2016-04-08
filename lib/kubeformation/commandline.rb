require 'thor'

module Kubeformation
  class Commandline < Thor
    package_name 'Kubeformation'
    map ['-v', '--version'] => :version

    class_option :source,      default: Dir.home + '/kubernetes', type: :string,  aliases: '-s', desc: 'Kubernetes source files.'
    class_option :destination, default: Dir.pwd + '/output',      type: :string,  aliases: '-d', desc: 'Destination output.'


    desc 'version', 'Print the version and exit.'
    def version
      puts Docfig::VERSION
    end

    desc 'bootstrap [key=value ...]', 'Bootstrap options'
    def bootstrap
      Kubeformation::Core.new(options).bootstrap
    end

    desc 'certificates [key=value ...]', 'Certificate options'
    method_option :master_internal_ip,        default: '10.0.0.1',               type: :string,  aliases: '-i', desc: 'Master internal IP.'
    method_option :master_name,               default: 'kubernetes.example.org', type: :string,  aliases: '-m', desc: 'Master name.'
    method_option :service_cluster_ip_range,  default: '10.0.0.0/16',            type: :string,  aliases: '-c', desc: 'Service cluster IP range.'
    method_option :dns_domain,                default: 'cluster.local',          type: :string,  aliases: '-n', desc: 'DNS domain.'
    def certificates
      Kubeformation::Core.new(options).certificates
    end

    desc 'tokens [key=value ...]', 'Token options'
    def tokens
      Kubeformation::Core.new(options).tokens
    end
  end
end
