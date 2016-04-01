module Kubeformation
  class Bootstrap
    def initialize(options)
      @options = options
    end

    def generate
      ENV['KUBE_TEMP']=@options[:destination]

      util = "source #{@options[:source]}/cluster/aws/util.sh"

      %x( bash -c '#{util} ; create-bootstrap-script' )
    end
  end
end


