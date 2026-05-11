-- Cargar opciones primero (sin plugins)
require("config.options")

-- Bootstrap lazy.nvim y cargar plugins
require("config.lazy")

-- Keymaps después de que los plugins estén disponibles
require("config.keymaps")

-- Autocomandos
require("config.autocmds")
