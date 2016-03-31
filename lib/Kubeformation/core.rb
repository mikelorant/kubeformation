module Kubeformation
  class Core
    def initialize(options={})
      @options = options

      @kube_root = Dir.home + '/kubernetes'
      @kube_temp = Dir.home + '/kube-temp'

      FileUtils.mkdir_p @kube_temp
    end

    def generate
      bootstrap_script
      kube_env
      user_data
      cleanup
    end

    private

    def bootstrap_script
      configure_vm = %x( sed '/^#+AWS_OVERRIDES_HERE/,$d' "#{@kube_root}/cluster/gce/configure-vm.sh" )
      configure_vm_aws = %x( cat "#{@kube_root}/cluster/aws/templates/configure-vm-aws.sh" )
      format_disks = %x( cat "#{@kube_root}/cluster/aws/templates/format-disks.sh" )
      configure_vm_extra = %x( sed -e '1,/^#+AWS_OVERRIDES_HERE/d' "#{@kube_root}/cluster/gce/configure-vm.sh" )

      contents = configure_vm + configure_vm_aws + format_disks + configure_vm_extra

      File.write("#{@kube_temp}" + "/bootstrap_script", contents)
    end

    def kube_env
      ENV['SERVER_BINARY_TAR_URL']=''
      ENV['SERVER_BINARY_TAR_HASH']=''
      ENV['SALT_TAR_URL']=''
      ENV['SALT_TAR_HASH']=''
      ENV['KUBE_USER']=''
      ENV['KUBE_PASSWORD']=''
      ENV['KUBE_BEARER_TOKEN']=''

      util = "source #{@kube_root}/cluster/aws/util.sh"
      common = "source #{@kube_root}/cluster/common.sh"
      source = "#{util} ; #{common}"

      %x( bash -c '#{source} ; build-kube-env true #{@kube_temp}/master-kube-env.yaml' )
      %x( bash -c '#{source} ; build-kube-env false #{@kube_temp}/node-kube-env.yaml' )
    end

    def user_data
      %w( master node ).each do |role|
        filename = "#{@kube_root}/cluster/aws/util.sh"

        file = File.readlines filename
        file_start = file.index{ |e| e =~ /write-#{role}-env/ }
        file_end = file.index{ |e| e =~ /#{role}-user-data/ }
        content = file[(file_start + 4)..(file_end - 1)].map{ |line| line.strip }

        content.collect! do |e|
          case e
          when /^cat/
            kube_yaml role
          when /^echo/
            var = e.split('"')[1]
            var =~ /yaml-quote/ ? var.gsub(/(.*:\ ).*yaml-quote\ (.*)\)/, '\1\2') : var
          else
            e
          end
        end

        File.write("#{@kube_temp}" + "/#{role}-user-data", content.join("\n"))
      end
    end

    def kube_yaml(role)
      File.readlines("#{@kube_temp}/#{role}-kube-env.yaml").map do |line|
        key, value = line.split(':',2)
        new_value = "${#{key}:-#{value.gsub(/[' ]/, '').chomp}}"
        line = "#{key}: '#{new_value}'"
      end
    end

    def cleanup
      %w( master node ).each do |role|
        File.delete("#{@kube_temp}/#{role}-kube-env.yaml")
      end
    end
  end
end
