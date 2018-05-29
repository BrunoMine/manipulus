--[[
	Mod Manipulus para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Inicializador de scripts
  ]]

-- Tabela global
manipulus = {}

-- Versão do projeto
manipulus.versao = "1.0"

-- Versoes compativeis
manipulus.versao_comp = {
}

-- Notificador de Inicializador
local notificar = function(msg)
	if minetest.setting_get("log_mods") then
		minetest.debug("[MANIPULUS]"..msg)
	end
end

-- Modpath
local modpath = minetest.get_modpath("manipulus")

-- Criação do banco de dados
manipulus.bd = dofile(modpath.."/lib/memor.lua")

-- Carregar scripts
notificar("Carregando...")
-- Metodos gerais
dofile(modpath.."/tradutor.lua")
-- API
dofile(modpath.."/bd_grupos.lua")
dofile(modpath.."/api.lua")
-- Nodes
dofile(modpath.."/demarcadores.lua")
-- Compatibilidades
dofile(modpath.."/protector.lua")
notificar("[OK]!")
