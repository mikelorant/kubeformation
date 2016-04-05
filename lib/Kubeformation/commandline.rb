require 'thor'

module Kubeformation
  class Commandline < Thor
    package_name 'Kubeformation'
    map ['-v', '--version'] => :version

    desc 'version', 'Print the version and exit.'

    def version
      puts Docfig::VERSION
    end

    desc 'generate [key=value ...]', 'Generate options'
    method_option :source,                    default: Dir.home + '/kubernetes', type: :string,  aliases: '-s', desc: 'Kubernetes source files.'
    method_option :destination,               default: Dir.pwd + '/output',      type: :string,  aliases: '-d', desc: 'Destination output.'
    method_option :master_ip,                 default: '10.0.0.1',               type: :string,  aliases: '-i', desc: 'Master name.'
    method_option :master_name,               default: 'kubernetes.example.org', type: :string,  aliases: '-m', desc: 'Master name.'
    method_option :service_cluster_ip_range,  default: '10.0.0.0/16',            type: :string,  aliases: '-c', desc: 'Service cluster IP range.'
    method_option :dns_domain,                default: 'cluster.local',          type: :string,  aliases: '-n', desc: 'DNS domain.'

    def generate
      Kubeformation::Core.new(options).generate
    end
  end
end
