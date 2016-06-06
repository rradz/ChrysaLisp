%include 'inc/func.inc'
%include 'inc/mail.inc'
%include 'class/class_vector.inc'
%include 'class/class_string.inc'

	fn_function sys/task_open_farm
		;inputs
		;r0 = name string object
		;r1 = number to spawn
		;outputs
		;r0 = array of mailbox id's
		;trashes
		;all but r4

		ptr name
		ulong length
		ptr ids
		ptr msg
		ulong cpu
		ulong index
		struct mailbox, mailbox

		;save task info
		push_scope
		retire {r0, r1}, {name, length}

		;create output array
		static_call sys_mem, alloc, {length * id_size}, {ids, _}

		;init temp mailbox
		static_call sys_mail, mailbox, {&mailbox}

		;start all tasks in parallel
		static_call sys_cpu, id, {}, {cpu}
		assign {0}, {index}
		loop_while {index != length}
			static_call sys_mail, alloc, {}, {msg}
			assign {name->string_length + 1 + kn_msg_child_size}, {msg->msg_length}
			assign {0}, {msg->msg_dest.id_mbox}
			assign {cpu}, {msg->msg_dest.id_cpu}
			assign {&mailbox}, {msg->kn_msg_reply_id.id_mbox}
			assign {cpu}, {msg->kn_msg_reply_id.id_cpu}
			assign {kn_call_task_child}, {msg->kn_msg_function}
			assign {&ids[index * id_size]}, {msg->kn_msg_user}
			static_call sys_mem, copy, {&name->string_data, &msg->kn_msg_child_pathname, \
										name->string_length + 1}, {_, _}
			static_call sys_mail, send, {msg}
			assign {index + 1}, {index}
		loop_end

		;wait for replys
		loop_while {index != 0}
			assign {index - 1}, {index}
			static_call sys_mail, read, {&mailbox}, {msg}
			assign {msg->kn_msg_reply_id.id_mbox}, {msg->kn_msg_user->id_mbox}
			assign {msg->kn_msg_reply_id.id_cpu}, {msg->kn_msg_user->id_cpu}
			static_call sys_mem, free, {msg}
		loop_end

		;return ids array
		eval {ids}, {r0}
		pop_scope
		vp_ret

	fn_function_end
