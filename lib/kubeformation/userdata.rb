module Kubeformation
  class Userdata < Common
    ROLE = %w( master node )

    def generate
      @logger.info 'Generating user data...'
      kube_env
      user_data
      cleanup
    end

    private

    def kube_env
      @logger.info 'Extracting yaml files...'

      ENV['SERVER_BINARY_TAR_URL']=''
      ENV['SERVER_BINARY_TAR_HASH']=''
      ENV['SALT_TAR_URL']=''
      ENV['SALT_TAR_HASH']=''
      ENV['KUBE_USER']=''
      ENV['KUBE_PASSWORD']=''
      ENV['KUBE_BEARER_TOKEN']=''

      util = "source #{@options[:source]}/cluster/aws/util.sh"
      common = "source #{@options[:source]}/cluster/common.sh"
      source = "#{util} ; #{common}"

      %x( bash -c '#{source} ; build-kube-env true #{@options[:destination]}/master-kube-env.yaml' )
      %x( bash -c '#{source} ; build-kube-env false #{@options[:destination]}/node-kube-env.yaml' )
    end

    def user_data
      @logger.info 'Transforming user data...'
      ROLE.each do |role|
        @role = role

        filename = "#{@options[:source]}/cluster/aws/util.sh"
        @file = File.readlines filename

        File.write("#{@options[:destination]}" + "/#{role}-user-data", transform.join("\n"))
      end
    end

    def user_data_block
      block_start = @file.index { |e| e =~ /write-#{@role}-env/ }          # Search for position of write-{role}-env
      block_end = @file.index { |e| e =~ /#{@role}-user-data/ }            # Search for position of {role}-user-data
      block = @file[block_start..block_end]

      block_start = block.index { |e| e =~ /#!/ }                          # Search for position of hashbang
      block_end = block.rindex { |e| e =~ /\/etc\/kubernetes\/bootstrap/ } # Search for last position of /etc/kubernetes/bootstrap

      block[block_start..block_end].map { |line| line.strip }              # Strip whitespaces from beginning and end
    end

    def transform
      user_data_block
        .insert(
          1,
          'if [ -f /var/tmp/certificates.sh ]; then',
          '  source /var/tmp/certificates.sh',
          'fi'
        )
        .collect do |line|
          case line
          when /^cat/
            inject_yaml
          when /^echo/
            sanitise_command line
          else
            line
          end
        end
    end

    def inject_yaml
      File.readlines("#{@options[:destination]}/#{@role}-kube-env.yaml").map do |line|
        transform_yaml_line line
      end
    end

    def transform_yaml_line(line)
      key, value = line.split(':',2) # Split key and value by first colon
      value = transform_yaml_value(key, value)

      "#{key}: '#{value}'"
    end

    def transform_yaml_value(key, value)
      value.gsub!(/[' ]/, '').chomp! # Remove single quote, spaces and trim whitespaces.
      "${#{key}:-#{value}}"          # Format: ${KEY:-VALUE}
    end

    def sanitise_command(command)
      remove_yaml_quote command.split('"')[1] # Split by first quote and take the 2nd item. Remove yaml quotes.
    end

    def remove_yaml_quote(command)
      regex = '(.*:\ ).*yaml-quote\ (.*)\)'                                 # Format:  KEY: $(yaml-quote ${VARIABLE:-VALUE})
      command =~ /yaml-quote/ ? command.gsub(/#{regex}/, '\1\2') : command  # Convert: KEY: VALUE
    end

    def cleanup
      ROLE.each do |role|
        File.delete("#{@options[:destination]}/#{role}-kube-env.yaml")
      end
    end
  end
end
