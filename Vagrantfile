NODES = 6
Vagrant.configure("2") do |config|
  (1..NODES).each do |i|
        config.vm.define "vm-#{i}" do |nodeconfig|
            nodeconfig.vm.hostname = "vm-#{i}"
            nodeconfig.vm.box = "bento/ubuntu-20.04"
            nodeconfig.vm.network :private_network, ip: "192.168.56.#{i + 10}"
        end
    end
end
