#!/bin/sh

on_exit() {
	trap - INT HUP QUIT TERM ALRM USR1
	echo "terminating online watchdog"
	exit 0
}

trap 'on_exit' INT HUP QUIT TERM ALRM USR1

initial_timeout=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].initialtimeout || echo "60")
ping_timeout=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].pingtimeout || echo "15")
ping_fail_timeout=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].pingfailtimeout || echo "5")
restart_delay=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].restartdelay || echo "5")
sequential_fails_limit=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].sequentialfailslimit || echo "3")
wifi_start=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].startwifi || echo "0")
wifi_stop=$(uci 2>/dev/null get online-watchdog.@online-watchdog[-1].stopwifi || echo "0")

targets_to_ping=$(uci 2>/dev/null -d"|" get online-watchdog.@online-watchdog[-1].pingtarget)
services_to_stop=$(uci 2>/dev/null -d"|" get online-watchdog.@online-watchdog[-1].stopservice)
services_to_start=$(uci 2>/dev/null -d"|" get online-watchdog.@online-watchdog[-1].startservice)
interfaces_to_stop=$(uci 2>/dev/null -d"|" get online-watchdog.@online-watchdog[-1].stopinterface)
interfaces_to_start=$(uci 2>/dev/null -d"|" get online-watchdog.@online-watchdog[-1].startinterface)

IFS="|"

log_info() {
	echo "$@" | logger -t "online-watchdog" -p info
}

log_warning() {
	echo "$@" | logger -t "online-watchdog" -p warn
}

fail_counter="0"

#state:
#0 - initialize, post reconnect
#1 - after successful ping
#2 - after ping fail
#3 - restart
#other - undefined
state="0"

pause() {
	case "${iface_device}" in
	0) sleep ${initial_timeout} ;;
	1) sleep ${ping_timeout} ;;
	2) sleep ${ping_fail_timeout} ;;
	3) sleep ${restart_delay} ;;
	*) sleep 1 ;;
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
		fi

		if [ "${fail_counter}" -gt "${sequential_fails_limit}" ]; then
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
			log_info "offline-recovery routine complete"
		fi
	done
done

log_warning "internal error: you should not see this message"
