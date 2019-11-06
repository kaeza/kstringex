
package = "kstringex"
version = "scm-0"

source = {
   url = "git://github.com/kaeza/kstringex",
}

description = {
	summary = "Extra string utilities.",
	homepage = "https://github.com/kaeza/kstringex",
	license = "MIT",
}

dependencies = {
	"lua >= 5.1, < 5.4",
}

build = {
	type = "builtin",
	modules = {
		["kstringex"] = "kstringex.lua",
	},
}
