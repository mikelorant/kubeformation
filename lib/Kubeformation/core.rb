module Kubeformation
  class Core
    def initialize(options={})
      @options = options

      FileUtils.mkdir_p @options[:destination]
    end

    def generate
      Kubeformation::Bootstrap.new(@options).generate
      Kubeformation::Userdata.new(@options).generate
      Kubeformation::Certificates.new(@options).generate
      Kubeformation::Tokens.new(@options).generate
    end
  end
end
