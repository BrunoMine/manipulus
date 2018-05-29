--[[
	Mod Manipulus para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Compatibilização com o mod protector
  ]]

-- Cancela se não estiver ativo
if minetest.get_modpath("protector") == nil then return end

local S = manipulus.S

-- Impede que um node seja colocado perto do outro
local old_on_place = {}
local impedir_node = function(node, node_evitado, r)
	if minetest.registered_nodes[node] ~= nil then
		old_on_place[node] = minetest.registered_nodes[node].on_place
		minetest.override_item(node, {
			on_place = function(itemstack, placer, pointed_thing)
				-- Verifica pos
				if pointed_thing == nil or pointed_thing.above == nil then
					return itemstack
				end
				local pos = pointed_thing.above
				
				-- Evitar coledir com protector (mesmo que seja do mesmo dono, não pode misturar as coisas)
				if minetest.find_node_near(pos, r, node_evitado) then
					minetest.chat_send_player(placer:get_player_name(), S("Area protegida nas proximidades"))
					return itemstack
				end
				
				if old_on_place[node] == nil then
					if not minetest.item_place(itemstack, placer, pointed_thing) then
						return itemstack
					end
					-- Remove item do inventario
					itemstack:take_item()

					return itemstack
				else
					return old_on_place[node](itemstack, placer, pointed_thing)
				end
			end,
		})
	end
end

impedir_node("manipulus:demarcador", "protector:protect", (protector.radius or 5)+5)
impedir_node("protector:protect", "manipulus:demarcador", (protector.radius or 5)+5)
impedir_node("manipulus:demarcador", "protector:protect2", (protector.radius or 5)+5)
impedir_node("protector:protect2", "manipulus:demarcador", (protector.radius or 5)+5)
