module Kubeformation
  class Bootstrap < Common
    def generate
      @logger.info 'Generating bootstrap...'
      ENV['KUBE_TEMP'] = @options[:destination]

      util = "source #{@options[:source]}/cluster/aws/util.sh"

      %x( bash -c '#{util} ; create-bootstrap-script' )
    end
  end
end
