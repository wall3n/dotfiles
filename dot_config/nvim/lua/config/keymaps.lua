local map = vim.keymap.set

-- ============================================================
-- NAVEGACIÓN BÁSICA (estilo ThePrimeagen)
-- ============================================================

-- Mover líneas seleccionadas en visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Mover selección abajo" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Mover selección arriba" })

-- J en normal mode no mueve el cursor
map("n", "J", "mzJ`z", { desc = "Join líneas sin mover cursor" })

-- Scroll centrado
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll abajo centrado" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll arriba centrado" })

-- Búsqueda centrada
map("n", "n", "nzzzv", { desc = "Siguiente resultado centrado" })
map("n", "N", "Nzzzv", { desc = "Anterior resultado centrado" })

-- Pegar sin perder el buffer
map("x", "<leader>p", [["_dP]], { desc = "Pegar sin perder buffer" })

-- Copiar al clipboard del sistema
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copiar al clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Copiar línea al clipboard" })

-- Borrar sin contaminar registros
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Borrar sin registro" })

-- Salir del modo insert con Ctrl+C (comportamiento idéntico a Escape)
map("i", "<C-c>", "<Esc>", { desc = "Salir insert mode" })

-- Desactivar Q (modo ex, raramente útil)
map("n", "Q", "<nop>")

-- ============================================================
-- SPLITS Y NAVEGACIÓN DE VENTANAS
-- ============================================================
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>se", "<C-w>=", { desc = "Igualar tamaño splits" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Cerrar split actual" })

-- Navegar splits con Ctrl + hjkl
map("n", "<C-h>", "<C-w>h", { desc = "Ir split izquierda" })
map("n", "<C-j>", "<C-w>j", { desc = "Ir split abajo" })
map("n", "<C-k>", "<C-w>k", { desc = "Ir split arriba" })
map("n", "<C-l>", "<C-w>l", { desc = "Ir split derecha" })

-- ============================================================
-- TABS
-- ============================================================
map("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Nueva tab" })
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Cerrar tab" })
map("n", "<leader>tn", "<cmd>tabnext<CR>", { desc = "Siguiente tab" })
map("n", "<leader>tp", "<cmd>tabprevious<CR>", { desc = "Tab anterior" })

-- ============================================================
-- BUFFERS
-- ============================================================
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Cerrar buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Buffer anterior" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Buffer siguiente" })

-- ============================================================
-- REEMPLAZAR WORD BAJO CURSOR (ThePrimeagen style)
-- ============================================================
map(
    "n",
    "<leader>rw",
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Reemplazar palabra bajo cursor" }
)

-- ============================================================
-- QUICKFIX / LOCATION LIST
-- ============================================================
map("n", "]q", "<cmd>cnext<CR>zz", { desc = "Quickfix siguiente" })
map("n", "[q", "<cmd>cprev<CR>zz", { desc = "Quickfix anterior" })
map("n", "]l", "<cmd>lnext<CR>zz", { desc = "Location list siguiente" })
map("n", "[l", "<cmd>lprev<CR>zz", { desc = "Location list anterior" })

-- ============================================================
-- CHMOD ejecutable (útil para scripts)
-- ============================================================
map("n", "<leader>cx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "chmod +x archivo actual" })

-- ============================================================
-- ABRIR CONFIGURACIÓN RÁPIDO
-- ============================================================
map("n", "<leader>ec", "<cmd>edit ~/.config/nvim/init.lua<CR>", { desc = "Editar config nvim" })
