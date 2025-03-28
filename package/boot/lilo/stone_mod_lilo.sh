# --- T2-COPYRIGHT-NOTE-BEGIN ---
# T2 SDE: package/*/lilo/stone_mod_lilo.sh
# Copyright (C) 2004 - 2025 The T2 SDE Project
# Copyright (C) 1998 - 2003 ROCK Linux Project
# 
# This Copyright note is generated by scripts/Create-CopyPatch,
# more information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2.
# --- T2-COPYRIGHT-NOTE-END ---
#
# [MAIN] 70 lilo LILO Boot Loader Setup
# [SETUP] 90 lilo

create_kernel_list() {
	local label= first=1 initrd=
	for x in `(cd /boot/; ls vmlinuz-*) | sort -Vr` ; do
		if [ $first = 1 ]; then
			label=linux first=0
		else
			label=linux-${x/vmlinuz-/}
		fi
		initrd=initrd-${x/vmlinuz_/}

		cat << EOT

image=/boot/$x
	label=$label
	append="root=$rootdev"
	initrd=/boot/$initrd
	read-only

EOT
	done
}

create_lilo_conf() {
	i=0 ; rootdev="`grep ' / ' /proc/mounts | tail -n 1 | \
					awk '/\/dev\// { print $1; }'`"
	rootdev="$( cd ${rootdev%/*} ; pwd -P )/${rootdev##*/}"
	# TODO: readlink?
	while [ -L $rootdev ] ; do
		directory="$( cd `dirname $rootdev` ; pwd -P )"
		rootdev="$( ls -l $rootdev | sed 's,.* -> ,,' )"
		[ "${rootdev##/*}" ] && rootdev="$directory/$rootdev"
		i=$(( $i + 1 )) ; [ $i -gt 20 ] && rootdev="Not found!"
	done
	bootdev="`echo $rootdev | sed -e 's,[0-9]*$,,'`"

	cat << EOT > /etc/lilo.conf
boot=$bootdev
delay=40
timeout=60
prompt
lba32
EOT

	create_kernel_list >> /etc/lilo.conf

	cat << EOT >> /etc/lilo.conf
image=/boot/memtest86.bin
	label=memtest
	optional
EOT
	gui_message "This is the new /etc/lilo.conf file:

$( cat /etc/lilo.conf )"

}

main() {

	if [ ! -f /etc/lilo.conf ]; then
	  if gui_yesno "LILO does not appear to be configured.
Automatically install LILO now?"; then
	    create_lilo_conf
	    if ! gui_cmd "Installing LILO in MBR" "lilo -v"; then
	      gui_message "There was an error while installing LILO."
	    fi
	  fi
	fi

	while

	gui_menu lilo 'LILO Boot Loader Setup' \
		'(Re-)Create lilo.conf with installed kernels' 'create_lilo_conf' \
		'(Re-)Install LILO in MBR of /dev/discs/disc0/disc' \
			'gui_cmd "Installing LILO in MBR" "lilo -v"' \
		"Edit /etc/lilo.conf (recommended before installing LILO)" \
			"gui_edit 'LILO Config File' /etc/lilo.conf"
    do : ; done
}
