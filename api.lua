--[[
	Mod Xpro para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	API
  ]]

-- Niveis de acoordo com XP
xpro.niveis = {
	0, -- Nivel 1
	150, -- Nivel 2
	300, -- Nivel 3
	600, -- Nivel 4
	900, -- Nivel 5
	1200, -- Nivel 6
	1500, -- Nivel 7
	2000, -- Nivel 8
	2500, -- Nivel 9
	3000, -- Nivel 10
	3500, -- Nivel 11
	4000, -- Nivel 12
	4600, -- Nivel 13
	5200, -- Nivel 14
	6000, -- Nivel 15
	6900, -- Nivel 16
	8000, -- Nivel 17
	9200, -- Nivel 18
	10500, -- Nivel 19
	11900, -- Nivel 20
	13400, -- Nivel 21
	15000, -- Nivel 22
	16700, -- Nivel 23
	18500, -- Nivel 24
	20400, -- Nivel 25
	22400, -- Nivel 26
	24500, -- Nivel 27
	26700, -- Nivel 28
	29000, -- Nivel 29
	31400, -- Nivel 30
	33900, -- Nivel 31
	36500, -- Nivel 32
	39200, -- Nivel 33
	42000, -- Nivel 34
	44900, -- Nivel 35
	47900, -- Nivel 36
	51000, -- Nivel 37
	54200, -- Nivel 38
	57500, -- Nivel 39
}
local tb_niveis = xpro.niveis

-- Pegar nivel de acordo com XP
local get_lvl = function(my_xp)
	local my_lvl = 1
	for lvl,xp in ipairs(tb_niveis) do
		if xp > my_xp then
			return my_lvl -- Retorna o nivel anterior
		end
		-- Tem o xp necessario para esse nivel
		my_lvl = lvl
	end
	return my_lvl
end

-- Pegar xp de um jogador (informar)
xpro.get_player_xp = function(name)
	return xpro.bd.pegar("jogador_"..name, "xp")
end

-- Pegar nivel de um jogador (informar)
xpro.get_player_lvl = function(name)
	return xpro.bd.pegar("jogador_"..name, "lvl")
end


-- Registro basico
minetest.register_on_joinplayer(function(player)
	
	-- Verifica se jogador ja possui registro no BD
	if xpro.bd.verif("jogador_"..player:get_player_name(), "xp") ~= true then
		
		-- Criar registro
		local tb_name = "jogador_"..player:get_player_name()
		
		-- XP
		xpro.bd.salvar(tb_name, "xp", 0)
		
		-- Nivel
		xpro.bd.salvar(tb_name, "lvl", 1)
		
	end
	 
end)


-- Callback ao adicionar XP
local callbacks_add_xp = {}
xpro.register_on_add_xp = function(func)
	table.insert(callbacks_add_xp, func)
end

-- Adicionar XP
xpro.add_xp = function(name, xp_add)

	-- Nome da tabela referente ao jogador no banco de dados
	local tb_name = "jogador_"..name
	
	local xp_atual = xpro.get_player_xp(name)
	
	-- Evita salvar xp negativo
	local new_xp = xp_atual+xp_add
	if new_xp < 0 then
		xpro.bd.salvar(tb_name, "xp", 0)
	else
		xpro.bd.salvar(tb_name, "xp", new_xp)
	end
	
	-- Atualiza nivel
	local old_lvl = xpro.get_player_lvl(name)
	local new_level = get_lvl(new_xp)
	xpro.bd.salvar(tb_name, "lvl", new_level)
	
	-- Executa callback registradas
	for _,func in ipairs(callbacks_add_xp) do
		func(name, xp_add, old_lvl ~= new_level)
	end
	
end


-- Callback ao remover XP
local callbacks_rem_xp = {}
xpro.register_on_rem_xp = function(func)
	table.insert(callbacks_rem_xp, func)
end

-- Remover XP
xpro.rem_xp = function(name, xp_rem)

	-- Nome da tabela referente ao jogador no banco de dados
	local tb_name = "jogador_"..name
	
	local xp_atual = xpro.get_player_xp(name)
	
	-- Evita salvar xp negativo
	local new_xp = xp_atual-xp_rem
	if new_xp < 0 then
		xpro.bd.salvar(tb_name, "xp", 0)
	else
		xpro.bd.salvar(tb_name, "xp", new_xp)
	end
	
	-- Atualiza nivel
	local old_lvl = xpro.get_player_lvl(name)
	local new_level = get_lvl(new_xp)
	xpro.bd.salvar(tb_name, "lvl", new_level)
	
	-- Executa callback registradas
	for _,func in ipairs(callbacks_rem_xp) do
		func(name, xp_rem, old_lvl ~= new_level)
	end
	
end








