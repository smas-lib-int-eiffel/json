note
	description: "Summary description for {JSON_TO_EIFFEL_CONVERTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_TO_EIFFEL_CONVERTER [G -> ANY create default_create end]

inherit
	INTERNAL

create
	do_convert

feature -- Initialization

	do_convert (a_json_object: JSON_OBJECT)
			--
		local
			l_template: like converted_object
			null_object: like converted_object
		do
			is_converted := True
			create l_template
			json_to_eiffel (a_json_object, l_template)
			if is_converted then
				converted_object := l_template
			else
				converted_object := null_object
			end
		end

feature -- Status report

	is_converted: BOOLEAN
			-- Was conversion ok ?

feature -- Access

	converted_object: detachable G
			-- Converted Eiffel object if conversion was ok.

	unknow_field_name: detachable STRING
			-- Name of last non matching field

feature -- Conversion

	json_to_eiffel (a_json_object: JSON_OBJECT; object: ANY)
			-- Fill an Eiffel `object' with `a_json_object'.
		local
			i: INTEGER
			l_value: JSON_VALUE
			l_name: STRING
		do
			across
				a_json_object as js
			loop
				l_value := js.item
				l_name := js.key.item.twin
				escape_keyword (l_name)
				from_camel_case (l_name)
				i := index_of_field (l_name, object)
				if i /= 0 or else l_name.starts_with ("_") then
					if attached {JSON_BOOLEAN} l_value as la_boolean then
						set_boolean_field (i, object, la_boolean.item)
					elseif attached {JSON_NUMBER} l_value as la_number then
						if la_number.is_natural then
							set_natural_64_field (i, object, la_number.item.to_natural)
						elseif la_number.is_integer then
							set_integer_field (i, object, la_number.item.to_integer)
						elseif la_number.is_real then
							set_real_field (i, object, la_number.item.to_real)
						end
					elseif attached {JSON_STRING} l_value as la_json_string then
						set_reference_field (i, object, la_json_string.unescaped_string_8)
					elseif attached {JSON_ARRAY} l_value as la_json_array then
						if attached reference_field (i, object) as la_object then
							json_array_to_eiffel (la_json_array, la_object)
						end
					elseif attached {JSON_OBJECT} l_value as la_json_object then
						json_object_to_eiffel (la_json_object, js.key.item, i, object)
					end
				else
					print ("Ignoring '" + l_name + "'%N")
				end
			end
		end

feature {NONE} -- Implementation

	index_of_field (a_field_name: STRING; object: ANY): INTEGER
			--
		local
			l_indexes: like field_indexes
		do
			l_indexes := field_indexes (object)
			Result := l_indexes.item (a_field_name)
		end

	from_camel_case (s: STRING)
			--
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i > s.count
			loop
				if s [i].is_upper then
					s [i] := s [i].lower
					s.insert_character ('_', i)
				end
				i :=i + 1
			end
		end

	escape_keyword (a_name: STRING)
			--
		do
			if a_name.is_equal ("result") then
				a_name.extend ('_')
			end
		end

	json_object_to_eiffel (a_json_object: JSON_OBJECT; a_name: STRING; i: INTEGER; object: ANY)
			--
		do
			if i = 0 then
				unknow_field_name := a_name
				is_converted := False
			else
				if attached reference_field (i, object) as la_object then
					json_to_eiffel (a_json_object, la_object)
				end
			end
		end

	eiffel_value (a_json_value: JSON_VALUE; object: detachable ANY): detachable ANY
			-- Eiffel value of `a_json_value'
		do
			if attached {JSON_VALUE} object as la_json_value then
				Result := a_json_value
			elseif attached {JSON_BOOLEAN} a_json_value as la_boolean then
				Result := la_boolean.item
			elseif attached {JSON_NUMBER} a_json_value as la_number then
				if la_number.is_natural then
					Result := la_number.item.to_natural
				elseif la_number.is_integer then
					Result := la_number.item.to_integer
				elseif la_number.is_real then
					Result := la_number.item.to_real
				end
			elseif attached {JSON_STRING} a_json_value as la_json_string then
				Result := la_json_string.item
--			elseif attached {JSON_ARRAY} l_value as la_json_array then
--				if attached reference_field (i, object) as la_object then
--					json_array_to_eiffel (la_json_array, la_object)
--				end
			elseif attached {JSON_OBJECT} a_json_value as la_json_object then
				if attached object as la_object then
					json_to_eiffel (la_json_object, la_object)
					Result := la_object
				end
			else
				Result := "???"
			end
		end

	json_array_to_eiffel (a_json_array: JSON_ARRAY; object: ANY)
			-- Fill an Eiffel `object' with `a_json_array'.
		local
			i, cnt: INTEGER
			l_inner: ANY
			l_gdt: INTEGER
		do
			l_gdt := generic_dynamic_type (object, 1)
			if attached {ARRAY [ANY]} object as la_array then
				across
					a_json_array as arr
				loop
					if attached new_container_item (l_gdt, arr.item) as la_item then
						la_array.force (la_item, i)
					end
				end
			elseif attached {COLLECTION [ANY]} object as la_collection then
				la_collection.wipe_out
				l_gdt := generic_dynamic_type (la_collection, 1)
				across
					a_json_array as arr
				loop
					if attached new_container_item (l_gdt, arr.item) as la_item then
						la_collection.extend (la_item)
					end
				end
			end
		end

	new_container_item (a_gdt: INTEGER; a_value: JSON_VALUE): detachable ANY
			--
		local
			l_inner: ANY
		do
			l_inner := new_instance_of (a_gdt)
			Result := eiffel_value (a_value, l_inner)
		end

	field_indexes (object: ANY): HASH_TABLE [INTEGER, STRING]
			--
		local
			i, cnt: INTEGER
		do
			cnt := field_count (object)
			create Result.make (cnt)
			from
				i := 1
			until
				i > cnt
			loop
				Result.put (i, field_name (i, object))
				i := i + 1
			end
		end

end
