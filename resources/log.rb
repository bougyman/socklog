actions :create, :delete
attribute :type, :kind_of => String, :equal_to => ["unix", "inet", "ucspi-tcp", "klog"], :default => "unix"
attribute :var_log_link, :kind_of => String
