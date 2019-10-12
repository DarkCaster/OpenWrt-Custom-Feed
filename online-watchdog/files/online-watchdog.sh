#!/bin/sh

# TODO: recreate this watchdog daemon with c\c++

log_info() {
	echo "$@" | logger -t "online-watchdog" -p info
}

log_warning() {
	echo "$@" | logger -t "online-watchdog" -p warn
}

on_exit() {
	trap - INT HUP QUIT TERM ALRM USR1
	log_info "terminating online watchdog"
	exit 0
}

trap 'on_exit' INT HUP QUIT TERM ALRM USR1

# TODO: add "is numeric" verification for the following parameters:
initial_timeout=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].initialtimeout || echo "60")
ping_timeout=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].pingtimeout || echo "15")
ping_fail_timeout=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].pingfailtimeout || echo "5")
restart_delay=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].restartdelay || echo "5")
sequential_fails_limit=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].sequentialfailslimit || echo "3")
recovery_fail_delay_mult=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].recoveryfaildelaymult || echo "2")
max_recovery_fail_delay=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].maxrecoveryfaildelay || echo "3600")

# TODO: add "is boolean" verification for the following parameters
wifi_start=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].startwifi || echo "0")
wifi_stop=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].stopwifi || echo "0")

targets_to_ping=$(uci 2>/dev/null -d"|" get online-watchdog.@online-watchdog[-1].pingtarget)
services_to_stop=$(uci 2>/dev/null -d"|" get online-watchdog.@online-watchdog[-1].stopservice)
services_to_start=$(uci 2>/dev/null -d"|" get online-watchdog.@online-watchdog[-1].startservice)
interfaces_to_stop=$(uci 2>/dev/null -d"|" get online-watchdog.@online-watchdog[-1].stopinterface)
interfaces_to_start=$(uci 2>/dev/null -d"|" get online-watchdog.@online-watchdog[-1].startinterface)

IFS="|"

recovery_fail_counter="-1"
fail_counter="0"

#state:
#0 - initialize, post reconnect
#1 - after successful ping
#2 - after ping fail
#3 - restart
#other - undefined
state="0"

long_pause() {
	local delay="$1"
	while [ "${delay}" -gt "0" ]; do
		if [ "$delay" -ge "5" ]; then
			sleep 5
			delay=$((delay - 5))
		else
			sleep ${delay}
			delay="0"
		fi
	done
}

recovery_fail_pause() {
	local sleep_time=$((recovery_fail_counter * recovery_fail_delay_mult))
	[ "${sleep_time}" -gt "${max_recovery_fail_delay}" ] && sleep_time="${max_recovery_fail_delay}" && recovery_fail_counter=$((recovery_fail_counter - 1))
	if [ "$sleep_time" -gt "0" ]; then
		log_info "sleeping for ${sleep_time} seconds after recovery failure"
		long_pause "${sleep_time}"
	fi
}

pause() {
	case "${state}" in
	"0")
		log_warning "sleeping for ${initial_timeout} seconds"
		long_pause ${initial_timeout}
		;;
	"1") sleep ${ping_timeout} ;;
	"2") sleep ${ping_fail_timeout} ;;
	"3")
		sleep ${restart_delay}
		recovery_fail_pause
		;;
	*)
		log_warning "invalid state ${state}"
		sleep 1
		;;
	esac
}

cut_quotes() {
	echo "$1" | sed "s/^'//" | sed "s/'$//"
}

stop_wifi() {
	if [ "${wifi_stop}" = "1" ]; then
		log_info "stopping wifi"
		wifi down
	fi
}

start_wifi() {
	if [ "${wifi_start}" = "1" ]; then
		log_info "(re)starting wifi"
		wifi
	fi
}

stop_services() {
	if [ ! -z "${services_to_stop}" ]; then
		for service in ${services_to_stop}; do
			log_info "stopping service ${service}"
			/etc/init.d/"${service}" stop
		done
	else
		log_info "no services to stop"
	fi
}

start_services() {
	if [ ! -z "${services_to_start}" ]; then
		for service in ${services_to_start}; do
			log_info "starting service ${service}"
			/etc/init.d/"${service}" start
		done
	else
		log_info "no services to start"
	fi
}

stop_interfaces() {
	if [ ! -z "${interfaces_to_stop}" ]; then
		for interface in ${interfaces_to_stop}; do
			log_info "stopping interface ${interface}"
			ifdown "${interface}"
		done
	else
		log_info "no interfaces to stop"
	fi
}

start_interfaces() {
	if [ ! -z "${interfaces_to_start}" ]; then
		for interface in ${interfaces_to_start}; do
			log_info "starting interface ${interface}"
			ifup "${interface}"
		done
	else
		log_info "no interfaces to start"
	fi
}

log_info "starting online-watchdog"

if [ -z "${targets_to_ping}" ]; then
	log_warning "no ping targets defined, nothing to do"
	while true; do
		sleep 60
	done
fi

while true; do
	for target in ${targets_to_ping}; do
		target=$(cut_quotes "${target}")
		pause

		ping 2>/dev/null 1>&2 -c 1 "${target}"
		if [ "$?" != "0" ]; then
			log_info "ping to target ${target} was failed"
			fail_counter=$((fail_counter + 1))
			state="2"
		else
			fail_counter="0"
			state="1"
			recovery_fail_counter="-1"
		fi

		if [ "${fail_counter}" -ge "${sequential_fails_limit}" ]; then
			recovery_fail_counter=$((recovery_fail_counter + 1))
			log_warning "system offline, recovering..."
			stop_services
			stop_wifi
			stop_interfaces
			state="3"
			pause
			start_interfaces
			start_wifi
			start_services
			state="0"
			fail_counter="0"
			log_info "offline-recovery routine complete"
		fi
	done
done

log_warning "internal error: you should not see this message"
