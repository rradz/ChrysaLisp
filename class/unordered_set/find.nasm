%include 'inc/func.inc'
%include 'class/class_unordered_set.inc'
%include 'class/class_vector.inc'

	def_function class/unordered_set/find
		;inputs
		;r0 = unordered_set object
		;r1 = key object
		;outputs
		;r0 = unordered_set object
		;r1 = 0, else found iterator
		;r2 = bucket vector
		;trashes
		;all but r0, r4

		def_structure local
			ptr local_inst
			ptr local_key
		def_structure_end

		;save inputs
		vp_sub local_size, r4
		set_src r0, r1
		set_dst [r4 + local_inst], [r4 + local_key]
		map_src_to_dst

		;search hash bucket
		s_call unordered_set, get_bucket, {r0, r1}, {r1}
		s_call vector, for_each, {r1, 0, $find_callback, r4}, {r1}
		vp_cpy r0, r2
		vp_cpy [r4 + local_inst], r0
		vp_add local_size, r4
		vp_ret

	find_callback:
		;inputs
		;r0 = element iterator
		;r1 = predicate data pointer
		;outputs
		;r1 = 0 if break, else not

		vp_cpy [r0], r0
		vp_cpy [r1 + local_inst], r2
		vp_cpy [r1 + local_key], r1
		vp_jmp [r2 + unordered_set_key_callback]

	def_function_end
