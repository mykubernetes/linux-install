{% raw -%}
#! /bin/bash
{% endraw %}

set -x -e

parts='{{ parts }}'
disk_name='{{ disk_name }}'
wipe_disk='{{ wipe_disk }}'
upgrade='{{ upgrade }}'
dry_run='{{ dry_run }}'

{% raw -%}

parts_len=$( echo "$parts" | jq -r ". | length" )
exist_parts=( $(parted $disk_name unit MB print 2>&1 | grep primary | awk '{print $4}' | sed -e 's/MB//g') )
wipe_disk=$( echo $wipe_disk | tr '[:upper:]' '[:lower:]' )
upgrade=$( echo $upgrade | tr '[:upper:]' '[:lower:]' )
dry_run=$( echo $dry_run | tr '[:upper:]' '[:lower:]' )

new_parts_tobe_added() {
    exist_parts_detail=( $(parted $disk_name unit MB print 2>&1 | grep primary | sed -e 's/MB//g') )
    exist_parts_length=$(parted $disk_name unit MB print 2>&1 | grep primary | wc -l)

    parts_to_added='[]'
    for i in $(seq $((exist_parts_length+1)) $parts_len);do
        bdev=$disk_name$i
        part=$(echo $parts | jq --arg bdev "$bdev" '.[]  | select(.bdev == $bdev)')
        parts_to_added=$(echo $parts_to_added | jq --argjson part "$part" '.[.| length] |= . + $part')
    done

    echo $parts_to_added
}

parts_added=$(new_parts_tobe_added)
parts_added_len=$( echo "$parts_added" | jq -r ". | length" )

check_dirty_partitions() {
    echo "found existing partitions, check partition number and partition sizes."

    if [[ $upgrade == "true" ]];then
        if [ ${#exist_parts[@]} -gt $parts_len ]; then
            echo "partition number is smaller than now! please check partitions for $disk_name"
            return 1
        fi
    else
        if [ ${#exist_parts[@]} != $parts_len ]; then
            echo "partition number not match! please check partitions for $disk_name"
	    return 1
	fi
    fi 

    for i in $(seq 1 ${#exist_parts[@]}); do
        index=$(( i - 1 ))
        exist=${exist_parts[index]}

        start=`echo "$parts" | jq -r ".[$index].capacity.start" | sed 's/[^0-9]*//g'`
        end=`echo "$parts" | jq -r ".[$index].capacity.end" | sed 's/[^0-9]*//g'`

        abs=$(( end - start - exist ))
        abs=${abs/#-/}

        if [[ $(( abs )) > 100 ]]; then
            echo "partition size not match! please check partitions for $disk_name"
            return 1
        fi
    done

    echo "partition number and sizes match. all good, nothing need to do."
    return 0
}

wipe_partitions() {
    echo "umount device and clear existing partitions."
    df -h | grep "$disk_name" | while read -r line; do
        mountpoint=$( echo $line | awk '{print $NF}' )
        umount $mountpoint
    done

    for p_num in $(parted -s $disk_name print | awk '/^ / {print $1}')
    do
       parted -s $disk_name rm ${p_num}
       RETVAL=$?
       if [ $RETVAL -ne 0 ]; then
           exit 1
       fi
    done

}

make_partitions() {
    echo "going to make partitions for disk $disk_name"

    args=" mklabel gpt "
    parts_tobe_make=$parts
    parts_tobe_make_len=$parts_len

    if [[ $upgrade == "true" ]];then
        args=" "
        parts_tobe_make=$parts_added
        parts_tobe_make_len=$parts_added_len
    fi

    for i in $(seq 1 $parts_tobe_make_len); do
        index=$(( i - 1 ))

        start=`echo "$parts_tobe_make" | jq -r ".[$index].capacity.start" | sed 's/[^0-9]*//g'`
        end=`echo "$parts_tobe_make" | jq -r ".[$index].capacity.end" | sed 's/[^0-9]*//g'`

        args=" $args mkpart primary xfs ${start}MB ${end}MB "
    done

    if [[ $dry_run == "true" ]];then
	    echo "dry run: parted -a optimal --script $disk_name $args"
	    exit 0
    fi

    parted -a optimal --script $disk_name $args
    RETVAL=$?

    if [ $RETVAL -ne 0 ]; then
        echo "partition failed!"
        exit $RETVAL
    fi

    sleep 3

    echo "partition finished."
}

mount_filesystems() {
    echo "going to mkfs and mount filesystems"

    parts_tobe_mount=$parts
    parts_tobe_mount_len=$parts_len

    if [[ $upgrade == "true" ]];then
        parts_tobe_mount=$parts_added
        parts_tobe_mount_len=$parts_added_len
    fi

    for i in $(seq 1 $parts_tobe_mount_len); do
        index=$(( i - 1 ))

        bdev=`echo "$parts_tobe_mount" | jq -r ".[$index].bdev"`
        path=`echo "$parts_tobe_mount" | jq -r ".[$index].path"`
        mkfs.xfs -n ftype=1 -f $bdev

        mkdir -p $path
        mount -o noatime $bdev $path

        if df -h | grep "$path"; then
            echo "mounted $path successfully"
        else
            echo "mounted $path failed."
            exit 1;
        fi

        uuid=`blkid -s UUID -o value $bdev`
        if cat /etc/fstab | grep -q $path; then
            # delete old entry from fstab
            grep -v $path /etc/fstab > temp; mv temp /etc/fstab
        fi
        # append new entry to fstab
        echo -e "UUID=$uuid $path \t xfs \t defaults,noatime \t 0 \t 0" >> /etc/fstab
    done
    echo "mount finished."
}

main() {
    echo "$( date )"
    echo "parted $disk_name start ==============================================================="

    if [[ $wipe_disk == 'true' ]]; then
        # clear all the parttions on disk and move on.
        wipe_partitions
    else
        if [[ -n $exist_parts ]]; then
            check_dirty_partitions
            is_dirty=$?
            if [[ $is_dirty == 1 ]] ; then
                # existing partitions are dirty, just return fail
                exit 1
            else
                # existing partitions are not dirty, just return success
                if [[ $upgrade == "false" ]];then
                    exit 0
	        fi
            fi
        else
            echo "donot find existing partitions, going to make some and mount them."
        fi
    fi

    make_partitions
    mount_filesystems

    echo "print partition tables:"
    parted $disk_name print

    parted_len=$( parted $disk_name print 2>&1 | grep primary | wc -l )
    if [ $parted_len == $parts_len ]; then
        echo -e "parted $disk_name finished. =============================================================== \n\n\n"
        exit 0
    else
        echo -e "parted $disk_name failed, please check logs in /tmp !.  \n\n\n"
        exit 1
    fi

}

main

{% endraw %}
