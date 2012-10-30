actions :create, :delete
default_action :create
attribute :log_name, :kind_of => String
attribute :type, :kind_of => String, :equal_to => ["unix", "inet", "ucspi-tcp", "klog"], :default => "unix"
attribute :var_log_link, :kind_of => String
attribute :size, :kind_of => Integer, :default => 100000000 # 10 Megs by default
attribute :num_files_max, :kind_of => Integer, :default => 10 # Max rotated logs to keep
attribute :num_files_min, :kind_of => Integer, :default => 5 # How many files to keep if we're running out of space
attribute :rotate_seconds, :kind_of => Integer, :default => 604800 # Rotate weekly by default
attribute :remote_syslog, :kind_of => Hash, :callbacks => { :ip => lambda { |hash| hash.keys.include? :ip } }
attribute :prefix, :kind_of => String
attribute :programs, :kind_of => Array
attribute :facility, :kind_of => String # If we only want to look at one facility
attribute :exclude_patterns, :kind_of => Array, :default => ["*"]
attribute :include_patterns, :kind_of => Array
attribute :include_error_patterns, :kind_of => Array
attribute :exclude_error_patterns, :kind_of => Array
attribute :post_processor, :kind_of => String
attribute :exclude_programs_from_main, :kind_of => Array, :default => []

