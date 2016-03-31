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

    def generate
      Kubeformation::Core.new(options).generate
    end
  end
end
