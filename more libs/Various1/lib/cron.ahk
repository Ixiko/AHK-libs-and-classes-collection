; TODO: Refactor
class Cron {

	requires() {
		return [String, Arrays, Math]
	}

	static cron_tab := "`n"
	static IsStarted := false
	static cron_job_num := 0

	__new() {
		throw Exception("Instatiation of class " this.__Class
				. " is not allowed", -1)
	}

	start() {
		delay := (((60 - A_Sec) * 1000) - A_MSec) * -1
		SetTimer CronTimer, %delay%
		Cron.isStarted := true
		return

		CronTimer:
			_timer := new Logger("class." A_ThisFunc)
			delay := (((60 - A_Sec) * 1000) - A_MSec) * -1
			Cron.scheduler(A_Min)
			SetTimer CronTimer, %delay%
			_timer.info("delay", delay)
		return _timer.exit()
	}

	stop() {
		Cron.isStarted := false
		SetTimer CronTimer, Off
		return ErrorLevel
	}

	reset() {
		Cron.cron_tab := "`n"
		Cron.cron_job_num := 0
	}

	scheduler(current_min) {
		static last_runs_min := -1

		if (!Cron.isStarted) {
			return -1
		}
		if (last_runs_min = current_min) {
			while (last_runs_min = current_min) {
				sleep 500
				current_min := A_Min
			}
		}

		expr := "\n(?P<number>\d+?):\s*"
				. "((\d+,)*" Cron.value2Expr(current_min) "(,\d+)*|\*)\s+"
				. "((\d+,)*" Cron.value2Expr(A_Hour) "(,\d+)*|\*)\s+"
				. "((\d+,)*" Cron.value2Expr(A_DD) "(,\d+)*|\*)\s+"
				. "((\d+,)*" Cron.value2Expr(A_MM) "(,\d+)*|\*)\s+"
				. "((\d+,)*" Cron.value2Expr(A_WDay) "(,\d+)*|\*)\s+"
				. "(?P<name>.+?)\s*\n"

		num_jobs := 0
		start := 1
		loop {
			job_found_at := RegExMatch(Cron.cron_tab, expr, job_, start)
			if (job_found_at) {
				num_jobs++
				%job_name%(job_number)
				start := job_found_at + StrLen(job_name) - 1
			}
		} until (job_found_at = 0)

		last_runs_min := current_min

		return num_job
	}

	addScheduler(cron_pattern, function_name) {
		this.cron_tab .= ++Cron.cron_job_num ":"
				. Cron.parseEntry(cron_pattern, function_name) "`n"
	}

	parseEntry(cron_pattern, function_name) {
		entry := cron_pattern.trimAll() " " function_name.trimAll()
		sub_expr := "(((\d+,)*\d+|(\d+-\d+,)*\d+-\d+|\*)(\/\d+)*)\s+"
		expr := "S)^" sub_expr.repeat(5) "(.+?)$"
		if (RegExMatch(entry, expr, cron_entry)) {
			minute := Cron.range2List(cron_entry1, 0, 59, A_Min)
			hour := Cron.range2List(cron_entry6, 0, 23, A_Hour)
			day := Cron.range2List(cron_entry11, 1, 31, A_MDay)
			month := Cron.range2List(cron_entry16, 1, 12, A_Mon)
			wday := Cron.range2List(cron_entry21, 1, 7, A_WDay)
			function := cron_entry26
			effective_entry := minute " "
					. hour " "
					. day " "
					. month " "
					. wday " "
					. function
		} else {
			effective_entry := ""
			throw Exception("Entry '" entry "' is rejected: " ErrorLevel)
		}
		return effective_entry
	}

	; TODO: Refactor
	range2List(range, min, max, actual=0) {
		if (range = "*") {
			return range
		}
		list_value := []
		RegExMatch(range, "(.+?)(\/(\d+))*$", range)
		if (range3 != "" && range1 != "*") {
			range := range1 "-" max
		} else if (range3 != "" && range1 = "*") {
			range := Mod(actual, range3) "-" max
		} else if (range3 != "" && range1 != "") {
			range := range1 "-" max
		}
		ranges := StrSplit(range, ",")
		loop % ranges.maxIndex() {
			if (RegExMatch(ranges[A_Index], "(?P<from>\d+)-(?P<to>\d+)"
					, range_)) {
				; range_from := Math.LimitTo(range_from, min, max)
				if (range_from < min || range_from > max) {
					throw Exception("Range out of bounds: " range_from
							. " (" min "-" max ")")
				}
				; range_to := Math.LimitTo(range_to, min, max)
				if (range_to < min || range_to > max) {
					throw Exception("Range out of bounds: " range_to "
							. (" min "-" max ")")
				}
				loop {
					list_value.push(range_from++)
				} until (range_from > range_to)
			} else if (RegExMatch(ranges[A_Index], "\d+", range_val)) {
				if (range_val < min || range_val > max) {
					throw Exception("Range out of bounds: " range_val
							. " (" min "-" max ")")
				}
				list_value.push(range_val)
			}
		}
		uni_list_vals := Arrays.distinct(list_value)
		if (range3 != "") {
			i := 1
			n := 0
			while (i <= uni_list_vals.maxIndex()) {
				if (mod(n, range3) != 0) {
					uni_list_vals.remove(i)
				} else {
					i++
				}
				n++
			}
		}
		list_values := ""
		for key, value in uni_list_vals {
			list_values .= (list_values = "" ? "" : ",") value
		}
		return list_values
	}

	value2Expr(value) {
		return "0*" RegExReplace(value, "^0*", "")
	}

}

