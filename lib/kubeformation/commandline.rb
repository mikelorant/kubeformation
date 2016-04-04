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
    method_option :source,         default: Dir.home + '/kubernetes', type: :string,  aliases: '-s', desc: 'Kubernetes source files.'
    method_option :destination,    default: Dir.pwd + '/output',      type: :string,  aliases: '-d', desc: 'Destination output.'

    def generate
      Kubeformation::Core.new(options).generate
    end
  end
end
