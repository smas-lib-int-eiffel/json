note
	description: "Summary description for {JASON_PRETTYFIER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_PRETTIFIER

inherit
	ANY
		redefine
			default_create
		end

feature -- Initialization

	default_create
			--
		do
			indentation := "%N"
		end

feature -- Basic operations

	prettified (string: STRING): STRING
			--
		local
			i: INTEGER
		do
			Result := string.twin
			from
				i := 1
			until
				i > Result.count
			loop
				inspect
					Result [i]
				when '{' then
					if not in_string and then Result [i + 1] /= '}'then
						increment_indentation
						Result.insert_string (indentation, i + 1)
					end
				when '}' then
					if not in_string and then Result [i - 1] /= '{'then
						decrement_indentation
						Result.insert_string (indentation, i)
						i := i + indentation.count
					end
				when '[' then
					if not in_string and then Result [i + 1] /= ']'then
						increment_indentation
						Result.insert_string (indentation, i + 1)
					end
				when ']' then
					if not in_string and then Result [i - 1] /= '['then
						decrement_indentation
						Result.insert_string (indentation, i)
						i := i + indentation.count
					end
				when ',' then
					if not in_string then
						Result.insert_string (indentation, i + 1)
					end
				when ':' then
					if not in_string then
						Result.insert_string (" ", i + 1)
						i := i + 1
					end
				when '"' then
					in_string := not in_string
				else

				end
				i := i + 1
			end
		end

feature {NONE} -- Implementation

	in_string: BOOLEAN

	Tab: STRING = "  "

	indentation: STRING

	increment_indentation
			--
		do
			indentation.append (Tab)
		end

	decrement_indentation
			--
		do
			indentation.keep_head (indentation.count - Tab.count)
		end

end -- class JASON_PRETTIFIER
