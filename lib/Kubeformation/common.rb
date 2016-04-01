require 'logger'

module Kubeformation
  class Common
    def initialize(options)
      @options = options

      @logger = Logger.new(STDOUT)
    end
  end
end
