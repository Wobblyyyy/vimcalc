/*
 * okay. so i'm writing this comment several months after i wrote the original
 * code. this was my first project using v, and as you can see, it's genuinely
 * terrible. that's all. i apologize if you try to understand whatever the
 * hell all of this means...
 */

import cli { Command, Flag }
import os
import strconv
import math
import readline
import time

const (
	desc_name    = 'clicalc'
	desc_version = '1.0.0'
	desc_cmd     = 'clicalc
Simple command line expression parser. Parses expressions recursively,
allows for nested expressions. Has a default left-to-right order of operations,
does not follow PEMDAS or whatever it is. Using the basic expression parsing
functionality is relatively straightforward: there are quite a few commands
available, all of which are relatively self-explanatory. clicalc also provides
an interactive mode, which can be started by using the subcommand i.

Interactive mode is the primary feature of clicalc and the reason it has any
utility whatsoever. To learn more, enter interactive mode, then type in
"help".
'
	desc_cmd_c      = 'Shorter alias for "calc".'
	desc_cmd_calc   = 'Parse an expression and calculate its output.'
	desc_cmd_vc     = 'Shorter alias for "vcalc".'
	desc_cmd_vcalc  = 'Same as "calc", but with more debugging and logging.'
	desc_cmd_avg    = 'Average a set of comma-delimited expressions or numbers.'
	desc_cmd_hypot  = 'Calculate the hypotenuse of two legs.'
	desc_cmd_vhypot = 'Same as "hypot", but with more debugging and logging.'
	desc_cmd_add    = 'Add two numbers together.'
	desc_cmd_vadd   = 'Same as "add", but with more debugging and logging.'
	desc_cmd_var    = 'Substitute values into an equation.'
	desc_cmd_vvar   = 'Same as "var", but with more debugging and logging.'
	desc_cmd_mvar   = 'Substitute multiple values into an equation with multiple variables.'
	desc_cmd_vmvar  = 'Same as "mvar", but with more debugging and logging.'
	desc_cmd_rsin   = 'Sine in radians mode.'
	desc_cmd_dsin   = 'Sine in degrees mode.'
	desc_cmd_rcos   = 'Cosine in radians mode.'
	desc_cmd_dcos   = 'Cosine in degrees mode.'
	desc_cmd_rtan   = 'Tangent in radians mode.'
	desc_cmd_dtan   = 'Tangent in degrees mode.'
	math_pi         = 3.14159265359
	math_rt_2       = 1.41421356237
)

fn main() {
	file_create_dir()

	mut cmd := Command{
		name: desc_name
		description: desc_cmd
		version: desc_version
	}

	mut cmd_c := Command{
		name: 'c'
		description: desc_cmd_c
		usage: '<name> expression'
		required_args: 1
		execute: cmd_calc_fn
	}
	cmd_calc := Command{
		name: 'calc'
		description: desc_cmd_calc
		usage: '<name> expression'
		required_args: 1
		execute: cmd_calc_fn
	}
	cmd_vcalc := Command{
		name: 'vcalc'
		description: desc_cmd_vcalc
		usage: '<name> expression'
		required_args: 1
		execute: cmd_vcalc_fn
	}
	cmd_vc := Command{
		name: 'vc'
		description: desc_cmd_vc
		usage: '<name> expression'
		required_args: 1
		execute: cmd_vcalc_fn
	}
	cmd_avg := Command{
		name: 'avg'
		description: desc_cmd_avg
		usage: '<name> num1,num2,num3...'
		required_args: 1
		execute: cmd_avg_nums
	}
	cmd_hypot := Command{
		name: 'hypot'
		description: desc_cmd_hypot
		usage: '<name> a b'
		required_args: 2
		execute: cmd_hypot_fn
	}
	cmd_vhypot := Command{
		name: 'vhypot'
		description: desc_cmd_vhypot
		usage: '<name> a b'
		required_args: 2
		execute: cmd_vhypot_fn
	}
	cmd_add := Command{
		name: 'add'
		description: desc_cmd_add
		usage: '<name> a b'
		required_args: 2
		execute: cmd_add_fn
	}
	cmd_vadd := Command{
		name: 'vadd'
		description: desc_cmd_vadd
		usage: '<name> a b'
		required_args: 2
		execute: cmd_vadd_fn
	}
	cmd_var := Command{
		name: 'var'
		description: desc_cmd_var
		usage: '<name> equation var_name:var_value_1,var_value_2'
		required_args: 2
		execute: cmd_var_fn
	}
	cmd_vvar := Command{
		name: 'vvar'
		description: desc_cmd_vvar
		usage: '<name> equation var_name:var_value_1,var_value_2'
		required_args: 2
		execute: cmd_vvar_fn
	}
	cmd_mvar := Command{
		name: 'mvar'
		description: desc_cmd_mvar
		usage: '<name> equation var_name_1:var_value_1,var_value_2 var_name_2:var_value_1'
		required_args: 3
		execute: cmd_mvar_fn
	}
	cmd_vmvar := Command{
		name: 'vmvar'
		description: desc_cmd_vmvar
		usage: '<name> equation var_name_1:var_value_1,var_value_2 var_name_2:var_value_1'
		required_args: 3
		execute: cmd_vmvar_fn
	}
	cmd_rsin := Command{
		name: 'rsin'
		description: desc_cmd_rsin
		usage: '<name> value'
		required_args: 1
		execute: cmd_rsin_fn
	}
	cmd_dsin := Command{
		name: 'dsin'
		description: desc_cmd_dsin
		usage: '<name> value'
		required_args: 1
		execute: cmd_dsin_fn
	}
	cmd_rcos := Command{
		name: 'rcos'
		description: desc_cmd_rcos
		usage: '<name> value'
		required_args: 1
		execute: cmd_rcos_fn
	}
	cmd_dcos := Command{
		name: 'dcos'
		description: desc_cmd_dcos
		usage: '<name> value'
		required_args: 1
		execute: cmd_dcos_fn
	}
	cmd_rtan := Command{
		name: 'rtan'
		description: desc_cmd_rtan
		usage: '<name> value'
		required_args: 1
		execute: cmd_rtan_fn
	}
	cmd_dtan := Command{
		name: 'dtan'
		description: desc_cmd_dtan
		usage: '<name> value'
		required_args: 1
		execute: cmd_dtan_fn
	}

	// internally called "clear"
	// externally called "interactive"
	// i'm just really lazy
	cmd_clear := Command{
		name: 'interactive'
		description: 'Enter "interactive mode."'
		usage: '<name>'
		required_args: 0
		execute: cmd_clear_fn
	}
	cmd_clear_short := Command{
		name: 'i'
		description: 'Enter "interactive mode."'
		usage: '<name>'
		required_args: 0
		execute: cmd_clear_fn
	}
	cmd_vclear_short := Command{
		name: 'vi'
		description: 'Enter "interactive mode."'
		usage: '<name>'
		required_args: 0
		execute: cmd_vclear_fn
	}

	cmd_c.add_flag(Flag{
		flag: .string
		required: false
		name: 'out'
		abbrev: 'o'
		description: 'Write the output to a specific file.'
	})

	cmd.add_command(cmd_c)
	cmd.add_command(cmd_calc)
	cmd.add_command(cmd_vc)
	cmd.add_command(cmd_vcalc)
	cmd.add_command(cmd_avg)
	cmd.add_command(cmd_hypot)
	cmd.add_command(cmd_vhypot)
	cmd.add_command(cmd_add)
	cmd.add_command(cmd_vadd)
	cmd.add_command(cmd_var)
	cmd.add_command(cmd_vvar)
	cmd.add_command(cmd_mvar)
	cmd.add_command(cmd_vmvar)
	cmd.add_command(cmd_rsin)
	cmd.add_command(cmd_dsin)
	cmd.add_command(cmd_rcos)
	cmd.add_command(cmd_dcos)
	cmd.add_command(cmd_rtan)
	cmd.add_command(cmd_dtan)

	cmd.add_command(cmd_clear)
	cmd.add_command(cmd_clear_short)
	cmd.add_command(cmd_vclear_short)

	cmd.setup()
	cmd.parse(os.args)
}

fn trim_whitespace(str string) string {
	mut ret := ''
	chars := str.split('')
	for i in 0 .. chars.len {
		c := chars[i]
		if c != ' ' && c != '\n' && c != '\t' {
			ret += c
		}
	}
	return ret
}

fn cmd_avg_nums(cmd Command) ? {
	unparsed_nums := cmd.args[0].split(',').filter(it.len > 0)
	mut cmd_str := '['
	for i := 0; i < unparsed_nums.len; i++ {
		num := unparsed_nums[i]
		if i != unparsed_nums.len - 1 {
			cmd_str += '$num+'
		} else {
			cmd_str += num
		}
	}
	cmd_str += ']/$unparsed_nums.len='
	parse_expr(cmd_str, false, 0)
}

fn calc_expr(a f64, b f64, op Operator, debug bool, nest_lvl int) f64 {
	if debug {
		debug_log('exprcalc', 'performing $op.str() on $a and $b', nest_lvl)
	}
	match op {
		.plus {
			return a + b
		}
		.minus {
			return a - b
		}
		.multiply {
			return a * b
		}
		.divide {
			if b == 0 {
				println('divide by zero error (attempted to divide $a by 0)')
				return 0
			}
			return a / b
		}
		.pow {
			return math.pow(a, b)
		}
		.root {
			return math.pow(a, 1.0 / b)
		}
	}
}

fn perform_func(a f64, func Func, debug bool, nest_lvl int) f64 {
	if debug {
		debug_log('exprfunc', 'performing function "$func.str()" on $a', nest_lvl)
	}
	match func {
		.sin { return math.sin(a) }
		.cos { return math.cos(a) }
		.tan { return math.tan(a) }
		.asin { return math.asin(a) }
		.acos { return math.acos(a) }
		.atan { return math.atan(a) }
		.sqrt { return math.pow(a, 0.5) }
		.cbrt { return math.pow(a, 1.0 / 3.0) }
		.deg { return a * (180 / math_pi) }
		.rad { return a * (math_pi / 180) }
		.round { return math.round(a) }
	}
}

fn syntax_check(chars []string, open string, close string) bool {
	mut t_open := 0
	mut t_close := 0
	mut i := 0
	mut last_idx := -1
	for ; i < chars.len; i++ {
		c := chars[i]
		if c == open {
			t_open += 1
			last_idx = i
		} else if c == close {
			t_close += 1
		}
	}
	if t_open != t_close {
		println('ERROR: mismatched brackets! OPEN and CLOSE count must be the same!')
		println('       bracket type: $open$close')
		println('       open  ("$open") count: $t_open')
		println('       close ("$close") count: $t_close')
		idx_min := if i - 15 > 0 { i - 15 } else { 0 }
		idx_max := if i + 15 < chars.len { i + 15 } else { chars.len - 1 }
		mut up := ''
		mut bl := ''
		if idx_min != 0 {
			up += '...'
			bl += '   '
		}
		for j := idx_min; j <= idx_max; j++ {
			up += chars[j]
			if j == i || j == chars.len - 1 {
				bl += '^ here (char #${i + 1} of $chars.len)'
			} else if last_idx != -1 && j == last_idx {
				bl += '^'
				if t_open - t_close == 1 {
					bl += ' '
				}
			} else {
				bl += ' '
			}
		}
		if idx_max != chars.len - 1 {
			up += '...'
		}
		if t_open - t_close >= 1 {
			bl += ' (missing end bracket)'
		}
		println('')
		println('       your syntax error was right around...')
		println('       $up')
		println('       $bl')
		println('')
		println('       tips to fix this issue:')
		println('       - make sure every "[" has a corresponding "]"')
		println('       - make sure every "{" has a corresponding "}"')
		println('       - make sure "[]" and "{}" pairs are logically written')
		return false
	}
	return true
}

// ladies and gentlemen (and nb folks)...
// the moment you've all been waiting for...
// some absolutely vile code.
// i can't even begin to explain how many problems there are with this.
// - repeated iterations...
// - messy function calls...
// - gigantic blocks of code...
// - recursion...
// well. don't say i didn't warn you.
fn parse_expr(oi string, debug bool, nest_lvl int) f64 {
	mut input := oi
	mut reduction_count := 0
	// do some stuff, only if we're on nest level 0 - if we're not on nest
	// level 0, there's no point in doing all this stuff because the only
	// way we get there is if we've already done all this stuff...
	// does that make any sense at all?
	if nest_lvl == 0 {
		// in interactive mode you can use (), but in regular single
		// command mode you can't do that - i'm too lazy to actually fix
		// my shitty code, so we're just gonna replace () with []
		for input.contains('(') {
			input = input.replace('(', '[')
		}
		for input.contains(')') {
			input = input.replace(')', ']')
		}
		// same thing with commas - they're supported in interactive mode,
		// but not in command line mode
		for input.contains(',') {
			input = input.replace(',', 'and')
		}
		// simplify empty bracket pairs... this shouldn't really happen,
		// but who cares? right?
		for input.contains('[]') {
			input = input.replace('[]', '')
			reduction_count += 1
		}
		// infer multiplication whenever there are adjacent brackets
		for input.contains('][') {
			input = input.replace('][', ']*[')
			debug_log('autocorrect', 'automatically inserted "]*[" in place of "]["',
				nest_lvl)
		}
		for input.contains('}[') {
			input = input.replace('}[', '}*[')
			debug_log('autocorrect', 'automatically inserted "}*[" in place of "}["',
				nest_lvl)
		}
		for i in 0 .. 9 {
			for input.contains('$i[') {
				input = input.replace('$i[', '$i*[')
				debug_log('autocorrect', 'automatically inserted "$i*[" in place of "$i["',
					nest_lvl)
			}
			for input.contains(']$i') {
				input = input.replace(']$i', ']*$i')
				debug_log('autocorrect', 'automatically inserted "]*$i" in place of "]$i"',
					nest_lvl)
			}
		}
		for input.contains('PI') || input.contains('pi') {
			input = input.replace('PI', math_pi.str()).replace('pi', math_pi.str())
			debug_log('autocorrect', 'automatically replaced "PI" with $math_pi.str()',
				nest_lvl)
		}
		// warn the user if they have any empty bracket pairs - there's not
		// much of a point in doing this, but just tell them they're basically
		// an idiot
		if reduction_count > 0 {
			println('WARN: empty bracket pairs found!')
			println('      empty bracket pair count: $reduction_count pair(s)')
			println('      performed bracket reduction')
			println('      original input length:  $oi.len')
			println('      optimized input length: $input.len')
		}
	}
	if debug {
		debug_log('parse', 'parsing expression "$input"', nest_lvl)
	}
	if input.len == 0 {
		return 0
	} else if input.contains('{}') {
		println('ERROR: cannot parse empty function!')
		println('       example valid function call:   "sin{3}"')
		println('       example invalid function call: "sin{}"')
		println('       make sure all curly brace pairs contain a valid expression!')
		println('')
		println('       input:')
		println('       $input')
		return 0
	}
	mut chars := input.split('')
	if chars[0] == '-' {
		// if there's a negative sign in front of the first expression,
		// just insert '0' before it so it acts just like subtraction.
		// this is potentially the worst solution possible, but it works.
		saved_chars := chars.clone()
		chars.clear()
		chars << '0'
		chars << saved_chars
	}
	// more stuff only for nest level 0 - attempt to perform bracket matching
	// in case the user didn't put the correct # of brackets in
	if nest_lvl == 0 {
		mut t_open_bracket := 0
		mut t_close_bracket := 0
		mut t_open_curly := 0
		mut t_close_curly := 0
		mut open_order := []string{}
		mut close_order := []string{}
		for i in 0 .. chars.len {
			c := chars[i]
			match c {
				'[' {
					t_open_bracket++
					open_order << '['
				}
				']' {
					t_close_bracket++
					close_order << ']'
				}
				'{' {
					t_open_curly++
					open_order << '{'
				}
				'}' {
					t_close_curly++
					close_order << '}'
				}
				else {}
			}
		}
		// this is really messy, but basically just add the brackets in the
		// reverse order that they appear
		if open_order.len > close_order.len {
			for i in close_order.len .. open_order.len {
				open := open_order[i]
				match open {
					'[' {
						input += ']'
						t_close_bracket++
						if debug {
							debug_log('autocorrect', 'automatically inserted "]"', nest_lvl)
						}
					}
					'{' {
						input += '}'
						t_close_curly++
						if debug {
							debug_log('autocorrect', 'automatically inserted "}"', nest_lvl)
						}
					}
					else {}
				}
			}
			chars = input.split('')
		}
		if debug {
			if !(t_open_bracket == 0 && t_close_bracket == 0) {
				debug_log('charcount', '"[" count: $t_open_bracket', nest_lvl)
				debug_log('charcount', '"]" count: $t_close_bracket', nest_lvl)
			}
			if !(t_open_curly == 0 && t_close_curly == 0) {
				debug_log('charcount', '"{" count: $t_open_curly', nest_lvl)
				debug_log('charcount', '"}" count: $t_close_curly', nest_lvl)
			}
		}
		// this is pretty bad - iterating over the string two more times...
		// but whatever, am i right?
		valid_brackets := syntax_check(chars, '[', ']')
		valid_curly := syntax_check(chars, '{', '}')
		if !valid_brackets || !valid_curly {
			if !valid_brackets && !valid_curly {
				println('ERROR: multiple types of mismatched braces/brackets!')
				println('       there was an error processing both types of brackets - {} and []')
				println('')
				println('       an error occured while processing the following input:')
				println('       "$input"')
				println('')
				println('       square brackets ("[]"):')
				println('       - open  ("[") count: $t_open_bracket')
				println('       - close ("]") count: $t_close_bracket')
				println('')
				println('       curly braces ("{}"):')
				println('       - open  ("{") count: $t_open_curly')
				println('       - close ("}") count: $t_close_curly')
			}
		}
	}
	// here we go... now we actually start parsing the expression. woot!
	//
	// unparsed_num                   - the unparsed number that's currently
	//                                  being worked with. this is a string
	//                                  that's updated while iterating
	//                                  over the string.
	// parsed_nums                    - an array of floats that contains all
	//                                  of the parsed numbers. these will
	//                                  always only be numbers, because
	//                                  expressions are evaluated before
	//                                  their value is included.
	// can_add_num                    - i'll be 100% honest... i have no idea
	//                                  why the hell this is here, but i
	//                                  don't want to remove it in case that
	//                                  messes anything up.
	// curr_op                        - the current operator. this is built
	//                                  just like unparsed_num and is reset
	//                                  whenever an operator is parsed
	mut unparsed_num := ''
	mut parsed_nums := []f64{}
	mut operators := []Operator{}
	mut can_add_num := true
	mut curr_op := ''
	// if there's no equals sign at the end, just add it so there's no
	// issues with not having the correct amount of operators
	if chars[chars.len - 1].str() != '=' {
		chars << '='
	}
	// iterate over the characters
	for i := 0; true; i++ {
		// i genuinely have no idea why i did it this way... i'm pretty sure
		// there was some issue with string mutability? once again, i'm too
		// lazy to fix this, so we're leaving it like this
		if i >= chars.len {
			break
		}
		c := chars[i]
		match c {
			// if it's a number or a . just add it to unparsed_num and
			// keep going
			'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.' {
				unparsed_num += c
			}
			// replace both % and N with a negative sign - this is here
			// because the first version of this app didn't have support for
			// leading negatives, and once again, i'm too lazy to remove it
			'%', 'N' {
				unparsed_num += '-'
			}
			'[' {
				// if there's a start bracket, perform nested expression
				// evaluation. more really shitty code incoming - you
				// have been warned.
				mut unparsed_expr_str := ''
				if debug {
					debug_log('parse', 'parsing bracket pair at index $i', nest_lvl)
				}
				// continue iterating over all of the characters until the
				// next close bracket is found
				if i + 1 != input.len {
					mut ctr := 0
					mut curly_ctr := 0
					for j := i + 1; j < input.len; j++ {
						curr_char := chars[j]
						if curr_char == '{' {
							curly_ctr += 1
						} else if curr_char == '}' {
							if curly_ctr == 0 {
								// check for unexpected characters - this
								// shouldn't ever happen
								println('ERROR: unexpected character "{"')
								println('       there was an unexpected character while processing:')
								println('       expecting: "]"')
								println('       input: "$input"')
								println('       current expression: "$unparsed_expr_str"')
								return 0
							}
							curly_ctr -= 1
						}
						// there can be multiple [] pairs inside of a single
						// expression, so we have to keep track of how many
						// pairs of brackets there are
						if curr_char == '[' {
							ctr += 1
							unparsed_expr_str += curr_char
						} else if curr_char == ']' {
							if ctr == 0 {
								break
							} else {
								unparsed_expr_str += curr_char
								ctr -= 1
							}
						} else {
							unparsed_expr_str += curr_char
						}
					}
					// parse the expression inside of the bracket pair
					val := parse_expr(unparsed_expr_str, debug, nest_lvl + 1)
					mut val_str := val.str()
					// literally what the fuck is this supposed to do lol
					// oh uh if the last character is . then just remove it
					// because floats have trailing dots for some reason
					if val_str.split('')[val_str.len - 1] == '.' {
						val_str = val_str.replace('.', '')
						parsed_nums << strconv.atoi(val_str) or { 0 }
					} else {
						parsed_nums << strconv.atof_quick(val_str)
					}
					// clear the chars array and push the new (modified)
					// char array w/out the expression we just parsed
					chars.clear()
					if debug {
						debug_log('parse', 'finished bracket parse with result "$val_str"',
							nest_lvl)
					}
					input = input.replace('[$unparsed_expr_str]', val_str)
					chars << input.split('')
					if val_str.len > 1 {
						i += val_str.len - 1
					}
				}
			}
			// don't do anything for close brackets, we handle all of that
			// stuff in the open bracket case
			']' {}
			// for any operators...
			'+', '-', '*', '/', '^', '=', '#' {
				if unparsed_num.len > 0 {
					// something about adding numbers - once again, not a clue
					// what this is supposed to be doing
					if can_add_num {
						parsed_nums << strconv.atof_quick(unparsed_num.replace('%', '-'))
						unparsed_num = ''
					} else {
						can_add_num = true
					}
				}
				// convert single characters into operators
				// unrelated, but it's really throwing me off how char
				// isn't a data type, but rather an identifier
				match c {
					'+' { operators << Operator.plus }
					'-' { operators << Operator.minus }
					'*' { operators << Operator.multiply }
					'/' { operators << Operator.divide }
					'^' { operators << Operator.pow }
					'#' { operators << Operator.root }
					else {}
				}
			}
			// basically the same thing as reguar bracket parsing, but for
			// operators or something like that
			'{' {
				mut unparsed := ''
				mut ctr := 0
				mut square_ctr := 0
				if debug {
					debug_log('parse', 'parsing curly brace pair at index $i', nest_lvl)
				}
				curr_op = trim_whitespace(curr_op)
				if i + 1 != input.len {
					for j := i + 1; j < input.len; j++ {
						curr_char := chars[j]
						if curr_char == '[' {
							square_ctr += 1
						} else if curr_char == ']' {
							if square_ctr == 0 {
								println('ERROR: unexpected character "]"')
								println('       there was an unexpected character while processing:')
								println('       expecting: "}"')
								println('       input: "$input"')
								println('       current expression: "$unparsed"')
								return 0
							}
							square_ctr -= 1
						}
						if curr_char == '{' {
							ctr += 1
						}
						if curr_char != '}' {
							unparsed += curr_char
						} else {
							if ctr == 0 {
								break
							} else {
								unparsed += '}'
							}
							ctr -= 1
						}
					}
					mut val := 0.0
					// dear god this is ugly
					// i am so sincerly sorry for the horrible mess you're
					// about to be exposed to
					if curr_op == 'log' {
						split := unparsed.split('base')
						if debug {
							debug_log('exprfunc', 'split log operands into $split', nest_lvl)
						}
						// split up log operands
						if split.len == 2 {
							u_unparsed_num := split[0]
							u_unparsed_base := split[1]
							num := parse_expr(u_unparsed_num, debug, nest_lvl + 1)
							base := parse_expr(u_unparsed_base, debug, nest_lvl + 1)
							l_num := math.log10(num)
							l_base := math.log10(base)
							val = l_num / l_base
						} else {
							// if there aren't any log operands just do log
							// base 10
							u_unparsed_num := split[0]
							num := parse_expr(u_unparsed_num, debug, nest_lvl + 1)

							val = math.log10(num)
						}
					} else if curr_op == 'avg' {
						// support averaging sets of numbers delimited by
						// the word "and" because commas don't work as
						// intended
						split := unparsed.split('and')
						if debug {
							debug_log('exprfunc', 'split avg operands into $split', nest_lvl)
						}
						mut expr := '['
						for m := 0; m < split.len; m++ {
							expr += '[${split[m]}]'
							if m != split.len - 1 {
								expr += '+'
							}
						}
						expr += ']/$split.len'
						val = parse_expr(expr, debug, nest_lvl + 1)
					} else if curr_op == 'read' {
						from_file := file_read(unparsed)
						val = parse_expr(from_file, debug, nest_lvl + 1)
					} else {
						val = parse_expr(unparsed, debug, nest_lvl + 1)
					}
					to_remove := '$curr_op' + '{' + unparsed + '}'
					// convert string functions into other functions
					match curr_op {
						'sin' {
							val = perform_func(val, Func.sin, debug, nest_lvl)
						}
						'cos' {
							val = perform_func(val, Func.cos, debug, nest_lvl)
						}
						'tan' {
							val = perform_func(val, Func.tan, debug, nest_lvl)
						}
						'asin' {
							val = perform_func(val, Func.asin, debug, nest_lvl)
						}
						'acos' {
							val = perform_func(val, Func.acos, debug, nest_lvl)
						}
						'atan' {
							val = perform_func(val, Func.atan, debug, nest_lvl)
						}
						'sqrt' {
							val = perform_func(val, Func.sqrt, debug, nest_lvl)
						}
						'cbrt' {
							val = perform_func(val, Func.cbrt, debug, nest_lvl)
						}
						'to_deg', 'rad_to_deg' {
							val = perform_func(val, Func.deg, debug, nest_lvl)
						}
						'to_rad', 'deg_to_rad' {
							val = perform_func(val, Func.rad, debug, nest_lvl)
						}
						'log', 'avg', 'read' {}
						'round' {
							val = perform_func(val, Func.round, debug, nest_lvl)
						}
						else {
							println('ERROR: invalid function!')
							println('       function name:   "$curr_op"')
							println('       parsed input:     $val')
							println('       unparsed input:   $unparsed')
							return 0
						}
					}
					mut val_str := val.str().replace('-', '%')
					chars.clear()
					if val_str.split('')[val_str.len - 1] == '.' {
						val_str = val_str.replace('.', '')
					}
					i += val_str.len - (curr_op.len + 1)
					input = input.replace(to_remove, val_str)
					chars << input.split('')
					curr_op = ''
					unparsed_num = val_str
					if debug {
						debug_log('parse', 'removing "$to_remove"', nest_lvl)
						debug_log('parse', 'finished curly parse with result "$val_str"',
							nest_lvl)
					}
				}
			}
			else {
				curr_op += c
			}
		}
	}
	// if there's still an unparsed number, parse it and add it to the
	// list of numbers
	if unparsed_num.len > 0 {
		parsed_nums << strconv.atof_quick(unparsed_num.replace('%', '-'))
		unparsed_num = ''
	}
	// if there's only a single parsed number, we know we've finished and
	// can just return it
	if parsed_nums.len == 1 {
		if debug {
			debug_log('parse', 'finished parsing expr $input', nest_lvl)
			debug_log('parse', 'result: ${parsed_nums[0].str()}', nest_lvl)
		}
		return parsed_nums[0]
	}
	if parsed_nums.len == 0 || operators.len == 0 {
		println('ERROR: expression could not be parsed because of missing numbers or operators.')
		println('       input expression:')
		println('       "$input"')
		println('')
		println('       PARAMS: numbers:   $parsed_nums.str()')
		println('       PARAMS: operators: $operators.str()')
		println('')
		println('       please ensure you provide at least...')
		println('       - 1 number')
		println('       - 1 operator')
		println('')
		println('       valid example:   "3+3="')
		println('       - invalid example: "3"')
		println('       - invalid example: "="')
		println('')
		println('       you might be attempting to parse a bit of text, such as:')
		println('       - "y"')
		println('       - "abc"')
		println('       if that is the case, make sure you are parsing numbers!')
		return 0
	}
	// add stuff like this
	// a + b + c + d + e
	// (a + b) + c + d + e
	// ((a + b) + c) + d + e
	// (((a + b) + c) + d) + e
	// ((((a + b) + c) + d) + e)
	// just condense everything down until there's only a single number
	for parsed_nums.len > 1 {
		if operators.len != parsed_nums.len - 1 {
			println('ERROR: invalid # of operators (either too few or too many)')
			println('       numbers count:   $parsed_nums.len')
			println('       operators count: $operators.len')
			if operators.len >= parsed_nums.len {
				println('')
				println('       too many operators!')
				println('       expected: ${parsed_nums.len - 1}')
				println('       found:    $operators.len')
			}
			println('')
			println('       dumping numbers')
			for i := 0; i < parsed_nums.len; i++ {
				println('       - ($i) ${parsed_nums[i]}')
			}
			println('')
			println('       dumping operators')
			for i := 0; i < operators.len; i++ {
				println('       - ($i) ${operators[i]}')
			}
			return 0
		}
		a := parsed_nums[0]
		b := parsed_nums[1]
		op := operators[0]
		result := calc_expr(a, b, op, debug, nest_lvl)
		parsed_nums.delete_many(0, 2)
		operators.delete(0)
		parsed_nums.insert(0, result)
	}
	if debug {
		debug_log('parse', 'finished parsing expr $input', nest_lvl)
		debug_log('parse', 'result: ${parsed_nums[0].str()}', nest_lvl)
	}
	// and we're done! i know you thought you'd never make it through this
	// disgusting mess of code, and, to be honest, i can't blame you. but you
	// did it! i'm so proud!
	return parsed_nums[0]
}

// interactive mode! who doesn't love interactive mode.
// this is a poorly named function, but i'm painfully lazy and don't feel
// like fixing it, so we're leaving it like this. sorry not sorry.
fn clear_fn(cmd Command, debug bool) {
	// this thing is used for reading user input
	mut rl := readline.Readline{}
	// random stats stuff
	mut cmd_count := 0
	mut parse_count := 0
	mut write_count := 0
	mut total_time := f64(0)
	// oh god... this is for the "add" and "exec" functions, but this is
	// really really shitty because v's support for maps isn't on the same
	// level as something like c# or java
	mut val_map := map[string][]string{}
	mut val_map_keys := []string{}
	// tell the user what's up. you know the vibe.
	println('Entered interactive mode.')
	println('To begin, type any valid expression.')
	println('To exit, type "exit".')
	println('For help/more info, type "help".')
	println('')
	mut last_val := 0.0
	// would you look at that? you can name for loops, that's pretty darn
	// swaggy, isn't it?
	outer: for true {
		// maybe there's an error reading user input. do i know why? nope.
		// but it might happen. you never know.
		mut input := rl.read_line('') or {
			println('ERROR: error reading user input')
			exit(1)
		}
		for input.contains('\n') {
			input = input.replace('\n', '')
		}
		for input.contains('last{}') {
			input = input.replace('last{}', last_val.str())
		}
		if input.contains('exit') {
			break
		} else if input.contains('form') {
			args := input.split(' ')
			// this is nothing short of absolutely disgusting code
			// i am genuinely very sorry for whoever is reading this
			// -- okay, i'm writing this comment about a month after i wrote
			// the first one. what. the fuck. does this shit. do. and why.
			// the fuck. did. i write. it. like this. i'm only putting this
			// comment here so i can dissociate myself completely from whatever
			// this horrible fucking mess of code is
			mut should_err := false
			if args.len == 3 {
				if args[1] != 'read' {
					should_err = true
				}
			} else if args.len < 4 {
				should_err = true
			}
			if should_err {
				println('ERROR: please make sure the formula (form) command has 4 or more arguments')
				println('')
				println('       example: saving a formula')
				println('       - "form save cool_formula [3+3+x]"')
				println('       - "form save cooler_formula [y+x*3]"')
				println('')
				println('       example: using a formula')
				println('       - "form read cool_formula x:3"')
				println('       - "form read cooler_formula x:3 y:4"')
				continue outer
			} else if args[0] != 'form' {
				println('ERROR: there was an error formatting the formula (form) command')
				println('       specifically, the first part of the split string was not parsed correctly.')
			} else {
				op := args[1]
				name := args[2]
				file_name := 'FORMULA_$name'
				// now match the operation! interactive mode has support for
				// more commands or whatever than command line mode
				match op {
					'save' {
						formula := args[3]
						file_write(file_name, formula)
					}
					'read' {
						mut formula := file_read(file_name)
						if args.len == 3 {
							println('> formula "$name":')
							println('> "$formula"')
						} else {
							for i in 3 .. args.len {
								unparsed_var := args[i]
								split_var := unparsed_var.split(':')
								if split_var.len != 2 {
									println('ERROR: invalid variable format')
									println('       please make sure your variable is formatted like so:')
									println('       - "x:3"')
									println('       - "y:10"')
									println('       - "z:[sqrt{10}+cbrt{2}]"')
									println('       and not like this:')
									println('       - (your input) $unparsed_var')
									continue outer
								}
								var_name := split_var[0]
								var_val := parse_expr(split_var[1], debug, 0).str()
								for formula.contains(var_name) {
									formula = formula.replace(var_name, var_val)
								}
							}
							time_start := time.now().unix
							val := parse_expr(formula, debug, 0)
							time_stop := time.now().unix
							time := time_stop - time_start
							println('> $val (${time}ms)')
							last_val = val
							total_time += time
							parse_count += 1
						}
					}
					else {
						println('ERROR: invalid formula operation!')
						println('       command line input:  "$input"')
						println('       parsed arguments:    $args.str()')
						println('       attempted operation: $op')
						continue outer
					}
				}
			}
		} else if input.contains('save') {
			split := input.split(' ')
			if split.len < 2 || split[0] != 'save' {
				if split.len < 2 {
					println('ERROR: please make sure the save command has exactly one argument')
				} else if split[0] != 'save' {
					println('ERROR: there was an error formatting the save command')
					println('       specifically, the first part of the split string was not parsed correctly.')
				}
				println('')
				println('       example format:')
				println('       "save xyz"')
				println('       "save cool_name"')
				println('')
				println('       using the save command:')
				println('       - to save the last value, do "save {name}"')
				println('         - "save cool_file"')
				println('         - "save cooler_file"')
				println('       - to save a new value, do "save {name} {expr}"')
				println('         - "save cool_file 3*3" (writes 9 to cool_file)')
				println('         - "save cooler_file avg{1and3}" (writes 2 to cooler_file)')
				continue outer
			}
			if split.len == 3 {
				name := split[1]
				val := parse_expr(split[2], debug, 0).str()
				file_write(name, val)
				write_count += 1
			} else {
				name := split[1]
				file_write(name, last_val.str())
				write_count += 1
			}
		} else if input.contains('help') {
			println('
### USING INTERACTIVE MODE
> interactive mode works just like the command line interface you used to
> start this program - it\'s a REPL (read eval print loop). every time you
> type in a command and press enter, the command you entered will be
> evaluated, and you will get some kind of output.

### REGULAR EXPRESSION EVALUATION
> if you just enter an expression without any other commands, the expression
> will be evaluated and the result will be printed. This is NOT RegEx, this
> is just normal expressions. You can use either square braces or regular
> braces ( () and [] ) to group expressions together so they will be completed
> sequentially.

### SAVING AND READING
> you can save and read values. ex:
>   [3+3+3]
>   save demo
> ... will save the result of 3+3+3 (9) to a file named "demo", which can
> then be accessed like so:
>   read{demo}+2
> ... that would output 11 (9 + 2 = 11).

### USING FORMULAS
> you can save and read a formula using the "form" command:
>   form save formula1 [x*[y + 3]]
>   form read formula1 x:0 y:1 ([0*[1 + 3]] = 0)
>   form read formula1 x:100 y:2 ([100*[2+3]] = 500)
> if you do something like...
>   form read formula1
> you\'ll get an output saying "[x*[y + 3]]"

### USING MULTI-VARIABLE EQUATIONS
> i honestly don\'t really remember what exactly my thought process was
> while adding this feature, so it might not make a lot of sense. but
> basically, the general idea is that you can "add" a bunch of variables,
> and then execute a single equation on all of them.
> you type something like...
>   add x 10
>   add y 10
>   add x 15
>   add y 20
>   exec [x+y] x y
> and then you\'ll get some results. i don\'t exactly know much of a better
> way to explain it, so i\'m hoping you get the point...
> 
> CLEARING MULTI-VARIABLE VALUES
> as of now, the only way to clear multi-variable values is by typing in
> "clear", as follows:
>   clear
> in the future, there will be a syntax like:
>   clear <variable name>
> example (clearing a variable named "testName"):
>   clear testName
>
> READING MULTI_VARIABLE VALUES
> to read all variables:
>   vars
>   vars <variable name>
> say you wanted to read a variable named "hello":
>   vars hello
> if you want to see the value of variables named "test1" and "test2":
>   vars test1 test2
>
> UNEVEN VARIABLE ARRAY LENGTHS
> if variables have uneven lengths like so:
>   x: [1, 2, 3]
>   y: [1, 2]
> ... it will use the last value of the array, as if the arrays were like this:
>   x: [1, 2, 3]
>   y: [1, 2, 2]

### SEEING STATISTICS 
> you can type "stats" to see some random statistics about your current
> interactive session. that is literally it.')
		} else if input.contains('stats') {
			println('CURRENT INTERACTIVE MODE STATS:')
			println('  commands executed:  $cmd_count')
			println('  expressions parsed: $parse_count')
			println('  files written:      $write_count')
			println('  time spent parsing: $total_time')
		} else if input.contains('clear') {
			tokens := input.split(' ')
			if tokens.len == 1 {
				// clear everything
				println('> clearing all variables')
				println('> $val_map_keys.str()')
				// for t in 0 .. val_map_keys.len {
				// val_key := val_map_keys[t]
				// val_map.delete(val_key)
				// val_map_keys.delete(t)
				// println('> cleared "$val_key"')
				// }
				val_map = map[string][]string{}
				val_map_keys = []string{}
			} else {
				for t in 1 .. tokens.len {
					var_name := tokens[t]
					if var_name in val_map {
						val_map[var_name] = []string{}
						println('> cleared "$var_name"')
					} else {
						println('> nothing to clear, "$var_name" was already empty')
					}
				}
			}
		} else if input.contains('vars') {
			tokens := input.split(' ')
			if tokens.len == 1 {
				println('> displaying all variables and their values...')
				for t in 0 .. val_map_keys.len {
					val_key := val_map_keys[t]
					println('> $val_key: ${val_map[val_key].str()}')
				}
			} else {
				for t in 1 .. tokens.len {
					var_name := tokens[t]
					println('> $var_name: ${val_map[var_name].str()}')
				}
			}
		} else if input.contains('add') {
			tokens := input.split(' ')
			if (tokens.len - 1) % 2 != 0 {
				println('
> ADD command requires an even number of arguments
>
> valid examples:
> add x 10
> add x 10 y 10 z 10 x 20 y 30 z 50
>
> invalid examples:
> add 10
> add x 10 x
')
				continue outer
			}
			for t := 1; t < tokens.len; t += 2 {
				var_name := tokens[t]
				var_value := tokens[t + 1]
				if var_value.contains(var_name) {
					println('ERROR: cannot have a variable that has itself as a value.')
					println('       this will cause an issue with recursion.')
					println('')
					println('       bad example:')
					println('       > add x sin{x}')
					println('')
					println('       good example:')
					println('       > add x 100')
					continue outer
				}
				if var_name !in val_map_keys {
					val_map_keys << var_name
				}
				if var_name !in val_map {
					val_map[var_name] = []string{}
				}
				if var_name !in val_map_keys {
					// ew there has to be a better way to do this
					mut stop := false
					for a := 0; a < val_map_keys.len && !stop; a++ {
						val_key := val_map_keys[a]
						println('A: $a KEY: $val_key')
						if var_name == val_key {
							val_map_keys.delete(a)
							println(' > deleted element $a (${val_map_keys[a]})')
							stop = true
						}
					}
				}
				val_map[var_name] << var_value
				println('> new value for $var_name: ${val_map[var_name].str()}')
			}
			mut len_map := map[string]int{}
			for e in 0 .. val_map_keys.len {
				val_key := val_map_keys[e]
				val_val := val_map[val_key]
				len_map[val_key] = val_val.len
			}
			mut max_len := 0.0
			mut min_len := 1_000_000.0
			for e in 0 .. val_map_keys.len {
				k := val_map_keys[e]
				max_len = math.max(max_len, len_map[k])
				min_len = math.min(min_len, len_map[k])
			}
		} else if input.contains('exec') {
			tokens := input.split(' ')
			if tokens.len < 3 {
				println('ERROR: expected at least 2 arguments, got $tokens.len
> example valid execution commands:
>   exec [x + y] x y
>   exec [x * [y * sin{z}]] x y z
> example invalid execution commands:
>   exec [x + y]
>   exec x y')
				continue outer
			}
			// good luck trying to understand what this means. i don't really
			// understand it, and i only wrote it a week ago.
			unparsed_expr := tokens[1]
			mut var_names := []string{}
			mut arrs := [][]string{}
			mut all_exprs := []string{}
			for i := 2; i < tokens.len; i++ {
				var_names << tokens[i]
			}
			for i in 0 .. var_names.len {
				var_name := var_names[i]
				arrs << val_map[var_name]
			}
			// alright. update. this is about 3 or so months after i wrote
			// this original piece of code, and i have absolutely no clue
			// where to even start with what this means...
			for i in 0 .. arrs[0].len {
				mut temp_expr := unparsed_expr
				for n in 0 .. var_names.len {
					var_name := var_names[n]
					for temp_expr.contains(var_name) {
						arr := arrs[n]
						arr_len := arr.len
						if i >= arr_len {
							temp_expr = temp_expr.replace(var_name, arr[arr_len - 1])
						} else {
							temp_expr = temp_expr.replace(var_name, arr[i])
						}
					}
				}
				all_exprs << temp_expr
			}
			for i in 0 .. all_exprs.len {
				println('> ${all_exprs[i].str()} = ${parse_expr(all_exprs[i], debug, 0)}')
			}
		} else if input.contains('vals') {
			println('> all currently stored values:')
			for e in 0 .. val_map_keys.len {
				k := val_map_keys[e]
				v := val_map[k]
				println('>   $k: $v.str()')
			}
		} else {
			time_start := time.now().unix
			val := parse_expr(input, debug, 0)
			time_stop := time.now().unix
			time := time_stop - time_start
			println('> $val')
			last_val = val
			total_time += time
			parse_count += 1
		}
		cmd_count += 1
		println('')
	}
}

fn cmd_clear_fn(cmd Command) ? {
	clear_fn(cmd, false)
}

fn cmd_vclear_fn(cmd Command) ? {
	clear_fn(cmd, true)
}

fn calc_fn(cmd Command, debug bool) {
	val := parse_expr(cmd.args[0], debug, 0)
	out_path := cmd.flags.get_string('out') or { return }
	if out_path.len == 0 {
	} else if out_path.len < 3 {
		println('ERROR: output file name must be 3 or more characters')
		println('       your file name: "$out_path"')
	} else {
		file_write(out_path, val.str())
		println('')
	}
	println('RESULT: $val')
}

fn cmd_calc_fn(cmd Command) ? {
	calc_fn(cmd, false)
}

fn cmd_vcalc_fn(cmd Command) ? {
	calc_fn(cmd, true)
}

fn cmd_hypot_fn(cmd Command) ? {
	a := cmd.args[0]
	b := cmd.args[1]
	val := parse_expr('sqrt{[$a^2]+[$b^2]}', false, 0)
	println('RESULT: $val')
}

fn cmd_vhypot_fn(cmd Command) ? {
	a := cmd.args[0]
	b := cmd.args[1]
	val := parse_expr('sqrt{[$a^2]+[$b^2]}', true, 0)
	println('RESULT: $val')
}

fn cmd_add_fn(cmd Command) ? {
	a := cmd.args[0]
	b := cmd.args[1]
	val := parse_expr('[$a]+[$b]', false, 0)
	println('RESULT: $val')
}

fn cmd_vadd_fn(cmd Command) ? {
	a := cmd.args[0]
	b := cmd.args[1]
	val := parse_expr('[$a]+[$b]', true, 0)
	println('RESULT: $val')
}

fn split_data(data string) (string, []string) {
	split_data := data.split(':')
	name := split_data[0]
	mut vals := split_data[1].split(',')
	for i := 0; i < vals.len; i++ {
		val := vals[i]
		mut go_down := false
		if val.contains('...') {
			go_down = true
			vals.delete(i)
			split_val := val.split('...')
			min := strconv.atoi(split_val[0]) or { 0 }
			max := strconv.atoi(split_val[1]) or { 0 }
			for j := min; j <= max; j++ {
				vals.insert(i, j.str())
				i++
			}
		} else if val.contains('..') {
			go_down = true
			vals.delete(i)
			split_val := val.split('..')
			min := strconv.atoi(split_val[0]) or { 0 }
			max := strconv.atoi(split_val[1]) or { 0 }
			for j := min; j < max; j++ {
				vals.insert(i, j.str())
				i++
			}
		}
		if go_down {
			i--
		}
	}
	return name, vals
}

fn var_fn(cmd Command, debug bool) {
	unparsed_equation := cmd.args[0]

	for i := 1; i < cmd.args.len; i++ {
		var_name, mut var_values := split_data(cmd.args[i])

		println('check: verifying equation syntax...')
		parse_expr(unparsed_equation.replace(var_name, math_rt_2.str()), debug, 0)
		println('check: successfully verified equation syntax')
		println('')

		println('check: verifying values for variable "$var_name"...')
		for j := 0; j < var_values.len; j++ {
			parse_expr(var_values[j], debug, 0)
		}
		println('check: successfully verified all $var_values.len values for variable "$var_name"')
		println('')

		if !unparsed_equation.contains(var_name) {
			println('ERROR: attempted to use an invalid variable')
			println('       attempted to use...')
			println('         var name: $var_name')
			println('         var vals: $var_values.str()')
			println('       input expression: $unparsed_equation')
			println('       make sure you are using the correct variable name!')
		}

		var_values.insert(0, '"$var_name"')

		mut max_len := f64(var_name.len) + 2.0
		for j := 0; j < var_values.len; j++ {
			value := var_values[j]
			max_len = math.max(max_len, value.len)
		}

		mut formatted_values := []string{}
		for j := 0; j < var_values.len; j++ {
			mut formatted_value := var_values[j]
			size_diff := max_len - formatted_value.len
			for k := 0; k < size_diff; k++ {
				formatted_value += ' '
			}
			formatted_values << formatted_value
		}

		for j := 0; j < var_values.len; j++ {
			val := if j != 0 { parse_expr(var_values[j], debug, 0) } else { 0.0 }
			mut equ_with_val := unparsed_equation

			if j != 0 {
				for equ_with_val.contains(var_name) {
					equ_with_val = equ_with_val.replace(var_name, val.str())
				}
			}

			result := if j == 0 { 'OUTPUT' } else { parse_expr(equ_with_val, debug, 0).str() }

			println('${formatted_values[j]}  |  $result')
		}
	}
}

fn cmd_var_fn(cmd Command) ? {
	var_fn(cmd, false)
}

fn cmd_vvar_fn(cmd Command) ? {
	var_fn(cmd, true)
}

fn validate_var(unparsed_equation string, var_name string, var_values []string) bool {
	if !unparsed_equation.contains(var_name) {
		println('ERROR: attempted to use an invalid variable')
		println('       attempted to use...')
		println('         var name: $var_name')
		println('         var vals: $var_values.str()')
		println('       input expression: $unparsed_equation')
		println('       make sure you are using the correct variable name!')
		return false
	} else {
		return true
	}
}

// format stuff for multivariable expressions
fn fmt_mvars(a []string, b []string) ([]string, []string) {
	if a.len != b.len {
		println('ERROR: "a" and "b" input arrays must be parallel')
		return []string{}, []string{}
	}
	mut max_len_a := 0.0
	mut max_len_b := 0.0
	for i := 0; i < a.len; i++ {
		max_len_a = math.max(max_len_a, a[i].len)
		max_len_b = math.max(max_len_b, b[i].len)
	}
	mut fmt_a := []string{}
	mut fmt_b := []string{}
	for i := 0; i < a.len; i++ {
		mut fmt_val_a := a[i]
		mut fmt_val_b := b[i]
		size_diff_a := max_len_a - fmt_val_a.len
		size_diff_b := max_len_b - fmt_val_b.len
		for j := 0; j < size_diff_a; j++ {
			fmt_val_a += ' '
		}
		for j := 0; j < size_diff_b; j++ {
			fmt_val_b += ' '
		}
		fmt_a << fmt_val_a
		fmt_b << fmt_val_b
	}
	return fmt_a, fmt_b
}

// multivariable expressions! this is pretty bad and i wouldn't suggest
// you use it, to be honest.
fn mvar_fn(cmd Command, debug bool) {
	unparsed_equation := cmd.args[0]

	var_name_a, mut var_values_a := split_data(cmd.args[1])
	var_name_b, mut var_values_b := split_data(cmd.args[2])

	valid_a := validate_var(unparsed_equation, var_name_a, var_values_a)
	valid_b := validate_var(unparsed_equation, var_name_b, var_values_b)

	if !valid_a || !valid_b {
		return
	}

	println('check: verifying equation syntax...')
	parse_expr(unparsed_equation.replace(var_name_a, math_rt_2.str()).replace(var_name_b,
		math_rt_2.str()), debug, 0)
	println('check: successfully verified equation syntax')
	println('')

	println('check: verifying values for variable "$var_name_a"...')
	for i := 0; i < var_values_a.len; i++ {
		parse_expr(var_values_a[i], debug, 0)
	}
	println('check: successfully verified all values for variable "$var_name_a"')
	println('')
	println('check: verifying values for variable "$var_name_b"...')
	for i := 0; i < var_values_a.len; i++ {
		parse_expr(var_values_b[i], debug, 0)
	}
	println('check: successfully verified all values for variable "$var_name_b"')
	println('')

	mut combos_a := []string{}
	mut combos_b := []string{}
	mut results := []string{}

	combos_a << var_name_a
	combos_b << var_name_b
	results << 'output'

	for ia := 0; ia < var_values_a.len; ia++ {
		va := var_values_a[ia]
		mut equ_with_val_a := unparsed_equation
		for equ_with_val_a.contains(var_name_a) {
			equ_with_val_a = equ_with_val_a.replace(var_name_a, va)
		}
		for ib := 0; ib < var_values_b.len; ib++ {
			vb := var_values_b[ib]
			mut equ_with_val_b := equ_with_val_a
			for equ_with_val_b.contains(var_name_b) {
				equ_with_val_b = equ_with_val_b.replace(var_name_b, vb)
			}
			combos_a << va
			combos_b << vb
			results << parse_expr(equ_with_val_b, debug, 0).str()
		}
	}

	combos_a, combos_b = fmt_mvars(combos_a, combos_b)

	for i := 0; i < combos_a.len; i++ {
		println('${combos_a[i]}  |  ${combos_b[i]}  |  ${results[i]}')
	}
}

fn cmd_mvar_fn(cmd Command) ? {
	mvar_fn(cmd, false)
}

fn cmd_vmvar_fn(cmd Command) ? {
	mvar_fn(cmd, true)
}

fn cmd_rsin_fn(cmd Command) ? {
	input := cmd.args[0]
	result := parse_expr('sin{$input}', false, 0)
	println('RESULT: $result')
}

fn cmd_dsin_fn(cmd Command) ? {
	input := cmd.args[0]
	result := parse_expr('sin{to_rad{$input}}', false, 0)
	println('RESULT: $result')
}

fn cmd_rcos_fn(cmd Command) ? {
	input := cmd.args[0]
	result := parse_expr('cos{$input}', false, 0)
	println('RESULT: $result')
}

fn cmd_dcos_fn(cmd Command) ? {
	input := cmd.args[0]
	result := parse_expr('cos{to_rad{$input}}', false, 0)
	println('RESULT: $result')
}

fn cmd_rtan_fn(cmd Command) ? {
	input := cmd.args[0]
	result := parse_expr('tan{$input}', false, 0)
	println('RESULT: $result')
}

fn cmd_dtan_fn(cmd Command) ? {
	input := cmd.args[0]
	result := parse_expr('tan{to_rad{$input}}', false, 0)
	println('RESULT: $result')
}

fn debug_log(prefix string, message string, nest_lvl int) {
	mut nest_prefix := '$nest_lvl '
	for i := nest_lvl; i != 0; i-- {
		nest_prefix += '  '
	}
	println('$nest_prefix$prefix: $message')
}

fn file_read(path string) string {
	loc := 'clicalc/$path'
	contents := os.read_file(loc) or {
		println('FILE: could not read file "$loc"')
		return ''
	}
	println('FILE: read file "$loc"')
	return contents
}

fn file_write(path string, contents string) {
	loc := 'clicalc/$path'
	if os.exists(loc) && !loc.contains('.old') && !loc.contains('.f') {
		copy_contents := os.read_file(loc) or {
			println('ERROR: file read error')
			exit(1)
		}
		file_write(path + '.old', copy_contents)
	}
	mut file := os.create(loc) or {
		println('ERROR: file open error')
		exit(1)
	}
	file.write_string(contents) or {
		println('ERROR: file write error')
		exit(1)
	}
	file.close()
	println('FILE: created file "$loc"')
}

fn file_remove(path string) {
	loc := 'clicalc/$path'
	if os.exists(loc) {
		os.rm(loc) or {
			println('ERROR: file remove error')
			exit(1)
		}
	}
}

fn file_create_dir() {
	loc := 'clicalc'
	if !os.exists(loc) {
		os.mkdir(loc) or {
			println('ERROR: clicalc directory create error')
			println('       directory name: clicalc')
			exit(1)
		}
	}
}

enum Operator {
	plus
	minus
	multiply
	divide
	pow
	root
}

enum Func {
	sin
	cos
	tan
	asin
	acos
	atan
	sqrt
	cbrt
	deg
	rad
	round
}

// and they said math is for nerds...
// honestly...
// come to think of it...
// they might be right.
// quite possibly.
