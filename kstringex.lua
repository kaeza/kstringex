
---
-- Extra string utilities.
--
-- @module kstringex
-- @author Diego Martínez <https://github.com/kaeza>
-- @license MIT. See `LICENSE.md` for details.

local kstringex = { }

---
-- Split a string.
--
-- @tparam string str String to split.
-- @tparam string sep Separator string or pattern.
-- @tparam ?boolean ispat If true, `sep` is treated as a Lua pattern.
--  If false, it's treated as a plain string. Default is false.
-- @tparam ?function filter Filter function. If specified, it should accept a
--  single argument (the part), and should return the value to be returned by
--  the iterator (may be any type other than nil), or nil to ignore the part.
-- @treturn function A function yielding the next part or nil if there
--  are no more parts.
function kstringex.isplit(str, sep, ispat, filter)
	local pos, endp = 1, #str + 1
	local isplain = not ispat
	filter = filter or tostring
	local function iter()
		if (not pos) or pos > endp then return end
		local s, e = str:find(sep, pos, isplain)
		local part = str:sub(pos, s and s - 1)
		pos = e and e + 1
		part = filter(part)
		if part == nil then return iter() end
		return part
	end
	return iter
end

---
-- Split a string.
--
-- @tparam string str String to split.
-- @tparam string sep Separator string or pattern.
-- @tparam ?boolean ispat If true, `sep` is treated as a Lua pattern.
--  If false, it's treated as a plain string. Default is false.
-- @tparam ?function filter Filter function. If specified, it should accept a
--  single argument (the part), and should return the value to be added to the
--  returned table (may be any type other than nil), or nil to ignore the part.
-- @treturn table A list of strings as a table.
function kstringex.split(str, sep, ispat, filter)
	local t, n = { }, 0
	for part in kstringex.isplit(str, sep, ispat, filter) do
		n = n + 1
		t[n] = part
	end
	return t
end

---
-- Trim whitespace around a string.
--
-- @tparam string str String to trim.
-- @treturn string Trimmed string.
function kstringex.trim(str)
	return str:match("^%s*(.-)%s*$")
end

---
-- Trim whitespace at the start of a string.
--
-- @tparam string str String to trim.
-- @treturn string Trimmed string.
function kstringex.ltrim(str)
	return str:match("^%s*(.*)")
end

---
-- Trim whitespace at the end of a string.
--
-- @tparam string str String to trim.
-- @treturn string Trimmed string.
function kstringex.rtrim(str)
	return str:match("(.*)%s*$")
end

---
-- Concatenate several values.
--
-- @tparam string sep Separator between strings.
-- @tparam function func Function expecting a single argument. It will
--  be called for each argument, and should return a string which will
--  be concatenated.
-- @tparam any ... Values to concatenate.
function kstringex.xconcat(sep, func, ...)
	local n, t = select("#", ...), { ... }
	for i = 1, n do
		t[i] = func(t[i])
	end
	return table.concat(t, sep or "")
end

---
-- Concatenate several values.
--
-- Equivalent to `xconcat(sep, tostring, ...)`.
--
-- @tparam string sep Separator between strings.
-- @tparam any ... Values to concatenate.
function kstringex.concat(sep, ...)
	return kstringex.xconcat(sep, tostring, ...)
end

---
-- Expand variable references.
--
-- This function expands variable references of the forms
-- `%VAR%`, `$VAR`, `%{VAR}`, and `${VAR}`. If `repl` is a
-- function, it is called with `VAR` as its only argument, and
-- should return a replacement string. If `repl` is a table,
-- `VAR` is used as key, and the resulting value must be a
-- string which will be used as replacement.
--
-- If the `err` function is specified it will be called on
-- invalid variable references with three values: the variable
-- name, the opening characters, and the closing characters,
-- in that order. If it returns a non-nil value, that value is
-- converted to a string and used as replacement. Otherwise,
-- invalid variable references are kept verbatim in the
-- returned string to aid in debugging.
--
-- @tparam string str String to expand.
-- @tparam table|function repl Replacement.
-- @tparam ?function err Function called in case of errors.
-- @treturn string The expanded string.
-- @treturn number The number of correct replacements.
function kstringex.expandvars(str, repl, err)
	if type(repl) == "table" then
		local r = repl
		repl = function(k) return r[k] end
	elseif type(repl) ~= "function" then
		error("replacement must be a table or function")
	end
	local nrepl = 0
	local function replace(open, var, close)
		if ((open == "%" and close == "%")
				or (open == "$" and close == "")
				or (open == "%{" and close == "}")
				or (open == "${" and close == "}")) then
			nrepl = nrepl + 1
			local v = repl(var)
			if v ~= nil then
				return tostring(v)
			else
				return ""
			end
		elseif err then
			local v = err(var, open, close)
			if v ~= nil then
				return tostring(v)
			end
		end
		return open..var..close
	end
	return str:gsub("([%%%$]{?)([A-Za-z0-9._:-]+)([}%%]?)", replace), nrepl
end

return kstringex
