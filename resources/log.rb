actions :create, :delete
attribute :type, :kind_of => String, :equal_to => ["unix", "inet", "ucspi-tcp", "klog"], :default => "unix"
attribute :var_log_link, :kind_of => String
attribute :time_stamp_opts, :kind_of => String, :default => '-t'



