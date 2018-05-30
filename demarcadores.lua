--[[
	Mod Manipulus para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Node demarcador de territorio
  ]]

local S = manipulus.S

-- Calcula valor de pontos de um novo demarcador para um determinado numero de demarcadores ja existentes um grupo
local calcular_pontos = function(n)
	return math.floor((0.8^n)*10)
end

-- Demarcador de territorio
minetest.register_node("manipulus:demarcador", {
	description = S("Demarcador de Territorio de Grupo"),
	tiles = {
		"default_steel_block.png", 
		"default_steel_block.png", 
		"default_steel_block.png^manipulus_demarcador_territorio.png", 
		"default_steel_block.png^manipulus_demarcador_territorio.png", 
		"default_steel_block.png^manipulus_demarcador_territorio.png", 
		"default_steel_block.png^manipulus_demarcador_territorio.png", 
	},
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_wood_defaults(),
	walkable = true,
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {-0.5,-0.5,-0.5,0.5,0.5,0.5},
	},
	
	on_place = function(itemstack, placer, pointed_thing)
		local name = placer:get_player_name()
		local grupo = manipulus.get_player_grupo(name)
		-- Verifica pos
		if pointed_thing == nil or pointed_thing.above == nil then
			return itemstack
		end
		local pos = pointed_thing.above
		
		-- Verificar grupo
		if grupo == nil then
			minetest.chat_send_player(name, S("Precisar ser lider ou fundador de um grupo para demarcar territorio"))
			return itemstack
		end
		
		-- Verificar se já está protegido
		for x=-1, 1 do
			for y=-1, 1 do
				for z=-1, 1 do
					if minetest.is_protected({x=pos.x+(5*x), y=pos.y+(5*x), z=pos.z+(5*x)}, name) == true then
						minetest.chat_send_player(name, S("Area protegida nas proximidades"))
						return itemstack 
					end
				end
			end
		end
		
		if not minetest.item_place(itemstack, placer, pointed_thing) then
			return itemstack
		end
		-- Remove item do inventario
		itemstack:take_item()

		return itemstack
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local name = placer:get_player_name()
		local grupo = manipulus.get_player_grupo(name)
		if grupo == nil then
			return
		end
		-- Verifica se não é um lider ou fundador
		local dados_grupo = manipulus.get_grupo(grupo)
		if dados_grupo.lideres[name] == nil and dados_grupo.fundador ~= name then
			return
		end
		
		-- Define demarcador
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Territorio de @1", grupo))
		meta:set_string("manipulus_grupo", grupo)
		meta:set_string("manipulus_grupo_numero", manipulus.bd.pegar("grupo_"..grupo, "numero"))
		manipulus.add_pontos_grupo(grupo, calcular_pontos(manipulus.get_demarcador_grupo(grupo))) -- conta o valor desse novo
		manipulus.add_demarcador_grupo(grupo) -- coloca o novo
	end,
	
	can_dig = function(pos, player)
		
		-- Verifica se grupo existe ainda
		local meta = minetest.get_meta(pos)
		local grupo = meta:get_string("manipulus_grupo")
		if grupo == "" or manipulus.existe_grupo(grupo) == false then
			return true
		end
		
		-- Verifica se é um lider ou fundador
		local name = player:get_player_name()
		local dados_grupo = manipulus.get_grupo(grupo)
		if dados_grupo.lideres[name] ~= nil or dados_grupo.fundador == name then
			return true
		end
		
		minetest.chat_send_player(name, S("Apenas fundador ou lider pode remover"))
		return false
	end,
	
	on_punch = function(pos, node, puncher)
		if manipulus.check_demarcador(pos) == false then return end
		manipulus.display_territorio({x=pos.x, y=pos.y, z=pos.z}, 5, "manipulus:display_territorio")
	end,
	
	on_destruct = function(pos)
		local meta = minetest.get_meta(pos)
		local grupo = meta:get_string("manipulus_grupo")
		if manipulus.existe_grupo(grupo)
			and manipulus.bd.verif("grupo_"..grupo, "numero") == true
			and meta:get_string("manipulus_grupo_numero") == tostring(manipulus.bd.pegar("grupo_"..grupo, "numero")) 
		then
			manipulus.rem_pontos_grupo(grupo, calcular_pontos(manipulus.get_demarcador_grupo(grupo)))
			manipulus.rem_demarcador_grupo(grupo)
		end
	end,
})
-- Receita 
minetest.register_craft({
	output = 'manipulus:demarcador',
	recipe = {
		{'group:stick', 'default:bronze_ingot', 'group:stick'},
		{'default:bronze_ingot', 'default:steelblock', 'default:bronze_ingot'},
		{'group:stick', 'default:bronze_ingot', 'group:stick'},
	}
})

-- Demarcador de subarea
minetest.register_node("manipulus:subarea", {
	description = S("Demarcador de subarea para membros de grupo"),
	tiles = {
		"default_wood.png", 
		"default_wood.png", 
		"default_wood.png^manipulus_demarcador_subarea.png", 
		"default_wood.png^manipulus_demarcador_subarea.png", 
		"default_wood.png^manipulus_demarcador_subarea.png", 
		"default_wood.png^manipulus_demarcador_subarea.png", 
	},
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_wood_defaults(),
	walkable = true,
	paramtype = "light",
	selection_box = {
		type = "fixed",
		fixed = {-0.5,-0.5,-0.5,0.5,0.5,0.5},
	},
	
	on_place = function(itemstack, placer, pointed_thing)
		local name = placer:get_player_name()
		local grupo = manipulus.get_player_grupo(name)
		-- Verificar grupo
		if grupo == nil then
			minetest.chat_send_player(name, S("Precisar ser lider ou fundador de um grupo para demarcar subareas"))
			return itemstack
		end
		
		if not minetest.item_place(itemstack, placer, pointed_thing) then
			return itemstack
		end
		-- Remove item do inventario
		itemstack:take_item()

		return itemstack
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local name = placer:get_player_name()
		local grupo = manipulus.get_player_grupo(name)
		if grupo == nil then
			return
		end
		-- Verifica se não é um lider ou fundador
		local dados_grupo = manipulus.get_grupo(grupo)
		if dados_grupo.lideres[name] == nil and dados_grupo.fundador ~= name then
			return
		end
		
		-- Define demarcador
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Bata aqui para definir dono da subarea"))
		meta:set_string("manipulus_grupo", grupo)
		meta:set_string("manipulus_grupo_numero", manipulus.bd.pegar("grupo_"..grupo, "numero"))
	end,
	
	on_punch = function(pos, node, player, pointed_thing)
		if manipulus.check_demarcador(pos) == false then return end
		
		local name = player:get_player_name()
		local grupo = manipulus.get_player_grupo(name)
		if grupo == nil then
			return
		end
		
		-- Verifica se não é membro do grupo
		if manipulus.existe_membro(grupo, name) == false then
			minetest.chat_send_player(name, S("Precisa ser membro para ser dono da subarea"))
			return
		end
		
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Subarea de "..name)
		meta:set_string("manipulus_dono", name)
		
		manipulus.display_territorio({x=pos.x, y=pos.y, z=pos.z}, 3, "manipulus:display_subarea")
	end,
	
	can_dig = function(pos, player)
		-- Verifica se grupo existe ainda
		local meta = minetest.get_meta(pos)
		local grupo = meta:get_string("manipulus_grupo")
		if grupo == "" or manipulus.existe_grupo(grupo) == false then
			return true
		end
		
		-- Verifica se é um lider ou fundador
		local name = player:get_player_name()
		local dados_grupo = manipulus.get_grupo(grupo)
		if dados_grupo.lideres[name] ~= nil or dados_grupo.fundador == name then
			
			return true
		end
		
		minetest.chat_send_player(name, S("Apenas fundador ou lider pode remover"))
		return false
	end,
})
-- Receita 
minetest.register_craft({
	output = 'manipulus:subarea',
	recipe = {
		{'group:stick', 'default:steel_ingot', 'group:stick'},
		{'default:steel_ingot', 'group:wood', 'default:steel_ingot'},
		{'group:stick', 'default:steel_ingot', 'group:stick'},
	}
})


-- Verifica se a coordenada 'pos' é protegida contra o jogador 'name'
manipulus.is_protected = function(pos, name)
	if name == "" or name == nil then return nil end
	-- Node demarcador dentro da area de risco (não deve existir mais de 1)
	local n = minetest.find_node_near(pos, 5, "manipulus:demarcador")
	if n then
		-- Verifica demarcador
		if manipulus.check_demarcador(n) == false then
			-- Ajuste realizado (removeu um mas pode ter outros, tenta denovo)
			return manipulus.is_protected(pos, name) 
		end
		-- Verifica se é do grupo
		local grupo = manipulus.get_player_grupo(name)
		if grupo == nil then
			minetest.chat_send_player(name, S("Territorio de @1", minetest.get_meta(n):get_string("manipulus_grupo")))
			return true
		end
		-- Verifica se é o mesmo grupo do node
		local meta = minetest.get_meta(n)
		if meta:get_string("manipulus_grupo") ~= grupo then
			minetest.chat_send_player(name, S("Territorio de @1", minetest.get_meta(n):get_string("manipulus_grupo")))
			return true
		end
		-- Verifica nivel hierarquico
		local dados_grupo = manipulus.get_grupo(grupo)
		-- Membros
		if dados_grupo.lideres[name] == nil and dados_grupo.fundador ~= name then
			-- Procura marcador de subarea
			for _,p in ipairs(minetest.find_nodes_in_area(
				vector.subtract(pos, 3),
				vector.add(pos, 3),
				"manipulus:subarea")) 
			do
				-- Verifica se é a subarea dele
				if minetest.get_meta(p):get_string("manipulus_dono") == name then
					return false
				end
			end
			minetest.chat_send_player(name, S("Como membro deves construir apenas na tua subarea designada pelos lideres"))
			return true
		-- Lideres e fundador
		else
			return false
		end
	else
		return nil -- Indefinido, repassa para o proximo mod verificar
	end
end
-- Sobreescreve metodo de proteção
local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, name)
	local r = manipulus.is_protected(pos, name)
	if r ~= nil then
		return r
	end
	return old_is_protected(pos, name)
end

---
-- Caixa de Area
------
-- Registro das entidades
minetest.register_entity("manipulus:display_territorio", {
	visual = "mesh",
	visual_size = {x=1,y=1},
	mesh = "manipulus_cubo.b3d",
	textures = {"manipulus_display_territorio.png"},
	collisionbox = {0,0,0, 0,0,0},
	timer = 0,
	
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer >= 5 then
			self.object:remove()
		end
	end,
})
minetest.register_entity("manipulus:display_subarea", {
	visual = "mesh",
	visual_size = {x=1,y=1},
	mesh = "manipulus_cubo.b3d",
	textures = {"manipulus_display_subarea.png"},
	collisionbox = {0,0,0, 0,0,0},
	timer = 0,
	
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer >= 5 then
			self.object:remove()
		end
	end,
})
-- Colocação de uma caixa
manipulus.display_territorio = function(pos, dist, name)
	
	-- Remove caixas proximas para evitar colisão
	for  _,obj in ipairs(minetest.get_objects_inside_radius(pos, 13)) do
		local ent = obj:get_luaentity() or {}
		if ent and ent.name == name then
			obj:remove()
		end
	end
	
	-- Cria o objeto
	local obj = minetest.add_entity({x=pos.x, y=pos.y, z=pos.z}, name)
	local obj2 = minetest.add_entity({x=pos.x, y=pos.y, z=pos.z}, name)
	obj2:set_properties({visual_size = {x=6, y=6}})
	
	-- Pega a entidade
	local ent = obj:get_luaentity()
	
	-- Redimensiona para o tamanho da area
	if tonumber(dist) == 1 then
		obj:set_properties({visual_size = {x=15, y=15}})
	elseif tonumber(dist) == 2 then
		obj:set_properties({visual_size = {x=25, y=25}})
	elseif tonumber(dist) == 3 then
		obj:set_properties({visual_size = {x=35, y=35}})
	elseif tonumber(dist) == 4 then
		obj:set_properties({visual_size = {x=45, y=45}})
	elseif tonumber(dist) == 5 then
		obj:set_properties({visual_size = {x=55, y=55}})
	elseif tonumber(dist) == 6 then
		obj:set_properties({visual_size = {x=65, y=65}})
	elseif tonumber(dist) == 7 then -- Na pratica isso serve para verificar area um pouco maior que as de largura 13
		obj:set_properties({visual_size = {x=75, y=75}})
	elseif tonumber(dist) == 8 then -- Na pratica isso serve para verificar area um pouco maior que as de largura 13
		obj:set_properties({visual_size = {x=85, y=85}})
	end
	return true
	
end
-------
-----
---

-- Verificar e remover demarcadores abandonados (cujo grupo foi desfeito)
manipulus.check_demarcador = function(pos)
	local meta = minetest.get_meta(pos)
	local grupo = meta:get_string("manipulus_grupo")
	if manipulus.existe_grupo(grupo)
		and manipulus.bd.verif("grupo_"..grupo, "numero") == true
		and meta:get_string("manipulus_grupo_numero") == tostring(manipulus.bd.pegar("grupo_"..grupo, "numero")) 
	then
		return true
	else
		minetest.remove_node(pos)
		-- Remover marcadores de subareas presentes
		for _,p in ipairs(minetest.find_nodes_in_area(
			vector.subtract(pos, 5),
			vector.add(pos, 5),
			"manipulus:subarea")) 
		do
			minetest.remove_node(p)
		end
		return false
	end
end

minetest.register_lbm({
	name = "manipulus:update_demarcador_lbm",
	nodenames = {"manipulus:demarcador", "manipulus:subarea"},
	run_at_every_load = true,
	action = function(pos, node)
		manipulus.check_demarcador(pos)
	end,
})

minetest.register_abm{
        label = "manipulus:update_demarcador_abm",
	nodenames = {"manipulus:demarcador", "manipulus:subarea"},
	interval = 60,
	chance = 1,
	action = function(pos)
		manipulus.check_demarcador(pos)
	end,
}


