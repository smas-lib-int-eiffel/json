note
	description: "Summary description for {JSON_UTIL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_FROM_EIFFEL_CONVERTER

inherit
	INTERNAL

feature -- Basic operation

	keep_void: BOOLEAN

	eiffel_to_json (object: ANY): JSON_OBJECT
			-- Eiffel `object' converted to Json
		local
			i, cnt: INTEGER
			l_name: STRING
			l_value: JSON_VALUE
		do
			cnt := field_count (object)
			create Result.make_empty
			from
				i := 1
			until
				i > cnt
			loop
				l_name := field_name (i, object)
				l_name.replace_substring_all ("hal_", "_")
				if l_name.is_equal ("digits") then
					print ("")
				end
				inspect
					field_type (i, object)
				when Boolean_type then
					l_value := json_value (boolean_field (i, object))
				when Integer_type then
					l_value := json_value (integer_field (i, object))
				when Natural_8_type then
					l_value := json_value (natural_8_field (i, object))
				when Natural_16_type then
					l_value := json_value (natural_16_field (i, object))
				when Natural_32_type then
					l_value := json_value (natural_32_field (i, object))
				when Natural_64_type then
					l_value := json_value (natural_64_field (i, object))
				when Real_type then
					l_value := json_value (real_field (i, object))
				when Reference_type then
					if attached reference_field (i, object) as la_reference then
						l_value := json_value (la_reference)
					else
						l_value := Void
					end
				else
--					l_value := Void
				end
				if l_value /= Void or else keep_void  then
					Result.put (l_value, l_name)
				end
				i := i + 1
			end
		end

	json_value (any: ANY): JSON_VALUE
			-- Json value of `any'
		do
			if attached {BOOLEAN} any as la_boolean then
				create {JSON_BOOLEAN} Result.make (la_boolean)
			elseif attached {NATURAL} any as la_natural then
				create {JSON_NUMBER} Result.make_natural (la_natural)
			elseif attached {NATURAL_8} any as la_natural then
				create {JSON_NUMBER} Result.make_natural (la_natural)
			elseif attached {NATURAL_16} any as la_natural then
				create {JSON_NUMBER} Result.make_natural (la_natural)
			elseif attached {NATURAL_32} any as la_natural then
				create {JSON_NUMBER} Result.make_natural (la_natural)
			elseif attached {NATURAL_64} any as la_natural then
				create {JSON_NUMBER} Result.make_natural (la_natural)
			elseif attached {INTEGER_8} any as la_integer then
				create {JSON_NUMBER} Result.make_integer (la_integer)
			elseif attached {INTEGER} any as la_integer then
				create {JSON_NUMBER} Result.make_integer (la_integer)
			elseif attached {REAL} any as la_real then
				create {JSON_NUMBER} Result.make_real (la_real)
			elseif attached {STRING} any as la_string then
				create {JSON_STRING}Result.make_from_string (la_string)
			elseif attached {HASH_TABLE [ANY, HASHABLE]} any as la_hash_table then
				Result := hash_table_to_json (la_hash_table)
			elseif attached {ITERABLE [ANY]} any as la_iterable then
				Result := iterable_to_json (la_iterable)
			else
				Result := eiffel_to_json (any)
			end
		end

	hash_table_to_json (a_hash_table: HASH_TABLE [ANY, HASHABLE]): JSON_ARRAY
			-- Json value of `iterable'
		local
			l_object: JSON_OBJECT
		do
			create Result.make_empty
			from
				a_hash_table.start
			until
				a_hash_table.off
			loop
				create l_object.make
				l_object.put (json_value (a_hash_table.item_for_iteration), create {JSON_STRING}.make_from_string ((a_hash_table.key_for_iteration).out))
				Result.extend (l_object)
				a_hash_table.forth
			end
		end

	iterable_to_json (iterable: ITERABLE [ANY]): JSON_ARRAY
			-- Json value of `iterable'
		local
			l_object: JSON_OBJECT
		do
			create Result.make_empty
			across
				iterable as it
			loop
				Result.extend (json_value (it.item))
			end
		end

end
