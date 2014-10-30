
proc set_bbox_list {args} {
	parse_proc_arguments -args $args p_args

	source [getenv SYNOPSYS]/auxx/syn/tmax/get_object_name.tcl
	set bmodule_list ""
	set file_handle [open $p_args(bbox_list_file) r]
	while { [gets $file_handle each_line] != -1} {
		if { [regexp # $each_line]!=1 } {
			## If line contains "#", it's comment line, drop it.
			lappend bmodule_list $each_line 
	    }
	}
	set bmodule_list [join $bmodule_list]

	# puts "debug: parsing file, bmodule_list = $bmodule_list"
	if {![info exists p_args(-quiet)]} {
		puts " Generating black-box module list..."
	}
	foreach mod $bmodule_list {
		redirect -variable valid_mod_name {get_module $mod}
		if { [regexp -all "Error: Cannot find" $valid_mod_name] == 1 } {
			## If the module file does not exist in memory, drop the element.
			if {![info exists p_args(-quiet)]} {
				puts " Removing invalid module name: $mod"
			}
			set bmodule_list [lminus -exact $bmodule_list $mod]
		} else {
			if {![info exists p_args(-quiet)]} {
				puts " Generating command: set_build -black_box $mod"
			}
			eval [set_build -black_box $mod]
		}
	}
	
	if {![info exists p_args(-quiet)]} {
		puts "\n Module(s) set as black_box:"
		eval [report_module -black_box]

		puts "\n Module(s) with undefined reference:"
		eval [report_module -undefined]
		puts " Please be aware of the difference of above lists."
	}
	return 1
}

define_proc_attributes set_bbox_list \
	-info "Read a filelist of black-box modules and parse the file to BUILD." \
	-define_args { \
		{bbox_list_file "Black-box module list file" bbox_list_file string required}
		{-quiet "Turn off printing message" "" boolean optional}
	}

