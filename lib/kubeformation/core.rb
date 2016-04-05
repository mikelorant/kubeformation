module Kubeformation
  class Core
    def initialize(options={})
      @options = options

      FileUtils.mkdir_p @options[:destination]
    end

    def bootstrap
      Kubeformation::Bootstrap.new(@options).generate
      Kubeformation::Userdata.new(@options).generate

    end

    def certificates
      Kubeformation::Certificates.new(@options).generate
    end

    def tokens
      Kubeformation::Tokens.new(@options).generate
    end
  end
end
