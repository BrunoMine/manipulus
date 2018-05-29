--[[
	Mod Manipulus para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Banco de dados de grupos
  ]]


-- Definir grupo do jogador
manipulus.set_player_grupo = function(jogador, grupo)
	manipulus.bd.salvar("Jogadores", jogador, grupo)
end

-- Pegar grupo do jogador
manipulus.get_player_grupo = function(jogador)
	if manipulus.bd.verif("Jogadores", jogador) then
		return manipulus.bd.pegar("Jogadores", jogador)
	else
		return nil
	end
end

-- Resetar grupo do jogador
manipulus.reset_player_grupo = function(jogador)
	manipulus.bd.remover("Jogadores", jogador)
end

-- Criar Grupo
manipulus.criar_grupo = function(grupo, def, fundador)
	
	-- Adiciona à estatistica
	manipulus.add_grupos_criados()
	local n = manipulus.get_grupos_criados()
	
	-- Demarcadores
	manipulus.bd.salvar("grupo_"..grupo, "demarcadores", 0)
	
	-- Numero do grupo
	manipulus.bd.salvar("grupo_"..grupo, "numero", n)
	
	-- Membros
	local membros = {}
	manipulus.bd.salvar("grupo_"..grupo, "membros", membros)
	
	-- Lideres
	local lideres = {}
	manipulus.bd.salvar("grupo_"..grupo, "lideres", lideres)
	
	-- Fundador
	manipulus.bd.salvar("grupo_"..grupo, "fundador", fundador)
	
	-- Descritivo do grupo
	manipulus.bd.salvar_texto("grupo_"..grupo, "descritivo", def.descritivo)
	
	-- Status de recrutamento
	manipulus.bd.salvar("grupo_"..grupo, "recrutamento", true)
	
	-- Quantidade de membros
	manipulus.bd.salvar("grupo_"..grupo, "qtd_membros", 0)
	
	-- Pontos do grupo
	manipulus.bd.salvar("grupo_"..grupo, "pontos", 0)
	
	manipulus.add_membro(grupo, fundador)
	manipulus.set_player_grupo(fundador, grupo)
	
end

-- Pegar dados de um grupo
manipulus.get_grupo = function(grupo)
	local dados = {}	
	
	-- Membros
	dados.membros = manipulus.bd.pegar("grupo_"..grupo, "membros")
	
	-- Lideres
	dados.lideres = manipulus.bd.pegar("grupo_"..grupo, "lideres")
	
	-- Fundador
	dados.fundador = manipulus.bd.pegar("grupo_"..grupo, "fundador")
	
	-- Descritivo do grupo
	dados.descritivo = manipulus.bd.pegar_texto("grupo_"..grupo, "descritivo")
	
	-- Status de recrutamento
	dados.recrutamento = manipulus.bd.pegar("grupo_"..grupo, "recrutamento")
	
	-- Quantidade de membros
	dados.qtd_membros = manipulus.bd.pegar("grupo_"..grupo, "qtd_membros")
	
	-- Pontos do grupo
	dados.pontos = manipulus.bd.pegar("grupo_"..grupo, "pontos")
	
	-- Demarcadores
	dados.demarcadores = manipulus.bd.pegar("grupo_"..grupo, "demarcadores")
	
	return dados
end

-- Deletar grupo
manipulus.deletar_grupo = function(grupo)
	-- Remover membros
	local membros = manipulus.bd.pegar("grupo_"..grupo, "membros")
	for membro,d in pairs(membros) do
		manipulus.reset_player_grupo(membro)
	end
	manipulus.bd.drop_tb("grupo_"..grupo)
	manipulus.rem_rank(grupo)
end

-- Verificar se grupo existe
manipulus.existe_grupo = function(grupo)
	return manipulus.bd.verif("grupo_"..grupo, "fundador")
end

-- Adicionar membro
manipulus.existe_membro = function(grupo, membro)
	local membros = manipulus.bd.pegar("grupo_"..grupo, "membros")
	if membros[membro] then
		return true
	else
		return false
	end
end

-- Adicionar membro
manipulus.add_membro = function(grupo, membro)
	if sfinv and minetest.get_player_by_name(membro) ~= nil then
		local player = minetest.get_player_by_name(membro)
		sfinv.set_player_inventory_formspec(player)
		sfinv.set_page(player, sfinv.get_homepage_name(player))
	end
	local membros = manipulus.bd.pegar("grupo_"..grupo, "membros")
	membros[membro] = {}
	manipulus.bd.salvar("grupo_"..grupo, "membros", membros)
	manipulus.set_player_grupo(membro, grupo)
	manipulus.bd.salvar("grupo_"..grupo, "qtd_membros", manipulus.bd.pegar("grupo_"..grupo, "qtd_membros")+1)
	manipulus.add_pontos_grupo(grupo, 1)
end

-- Remover membro
manipulus.rem_membro = function(grupo, membro)
	if sfinv and minetest.get_player_by_name(membro) ~= nil then
		local player = minetest.get_player_by_name(membro)
		sfinv.set_player_inventory_formspec(player)
		sfinv.set_page(player, sfinv.get_homepage_name(player))
	end
	-- Se for o fundador, desfaz o grupo
	if manipulus.get_grupo(grupo).fundador == membro then
		manipulus.deletar_grupo(grupo)
	
	-- Remove do grupo
	else
		manipulus.rem_pontos_grupo(grupo, 1)
		local membros = manipulus.bd.pegar("grupo_"..grupo, "membros")
		membros[membro] = nil
		manipulus.bd.salvar("grupo_"..grupo, "membros", membros)
		manipulus.rem_lider(grupo, membro)
		manipulus.reset_player_grupo(membro)
		manipulus.bd.salvar("grupo_"..grupo, "qtd_membros", manipulus.bd.pegar("grupo_"..grupo, "qtd_membros")-1)
	end
end

-- Adicionar lider
manipulus.add_lider = function(grupo, membro)
	local lideres = manipulus.bd.pegar("grupo_"..grupo, "lideres")
	lideres[membro] = {}
	manipulus.bd.salvar("grupo_"..grupo, "lideres", lideres)
end

-- Remover lider
manipulus.rem_lider = function(grupo, membro)
	local lideres = manipulus.bd.pegar("grupo_"..grupo, "lideres")
	if lideres[membro] then	lideres[membro] = nil end
	manipulus.bd.salvar("grupo_"..grupo, "lideres", lideres)
end

-- Atualizar membro
manipulus.set_membro = function(grupo, membro, dados)
	local membros = manipulus.bd.pegar("grupo_"..grupo, "membros")
	membros[membro] = dados
	manipulus.bd.salvar("grupo_"..grupo, "membros", membros)
end

-- Adicionar pontos
manipulus.add_pontos_grupo = function(grupo, pontos_add)
	local pontos = manipulus.bd.pegar("grupo_"..grupo, "pontos") + pontos_add
	manipulus.bd.salvar("grupo_"..grupo, "pontos", pontos)
	manipulus.update_rank(grupo)
end

-- Retirar pontos
manipulus.rem_pontos_grupo = function(grupo, pontos_rem)
	local pontos = manipulus.bd.pegar("grupo_"..grupo, "pontos") - pontos_rem
	if pontos < 0 then pontos = 0 end
	manipulus.bd.salvar("grupo_"..grupo, "pontos", pontos)
	manipulus.update_rank(grupo)
end

-- Pegar ranking
manipulus.get_rank = function()
	return manipulus.bd.pegar("Ranking", "pontos")
end

-- Remover do ranking
manipulus.rem_rank = function(grupo)
	local rank = manipulus.get_rank()
	for x=1, 10 do
		if grupo == rank[tostring(x)].grupo then
			rank[tostring(x)] = {grupo="Colocado "..x, pontos=0}
			break
		end
	end
	manipulus.bd.salvar("Ranking", "pontos", rank)
end

-- Atualizar ranking
manipulus.update_rank = function(grupo)
	local rank = manipulus.get_rank()
	local pontos = manipulus.bd.pegar("grupo_"..grupo, "pontos")
	local m1 = {grupo=grupo,pontos=pontos}
	local m2 = {}
	for x=1, 10 do
		-- Se o objeto atual for o novo colocado
		if m1.grupo == grupo then
			-- Verifica se fica no lugar
			if rank[tostring(x)].pontos < m1.pontos then
			
				--Substitui posicao
				m2.grupo = rank[tostring(x)].grupo
				m2.pontos = rank[tostring(x)].pontos
				rank[tostring(x)].grupo = m1.grupo
				rank[tostring(x)].pontos = m1.pontos
				
				-- Verifica se o que foi tirado é ele mesmo
				if grupo == m2.grupo then
					break
				end
				
				-- m2 para a ser m1 para a proxima comparacao
				m1.grupo = m2.grupo
				m1.pontos = m2.pontos
				
			-- Nao é maior mas é o mesmo grupo
			elseif m1.grupo == rank[tostring(x)].grupo then
				-- atualiza os pontos e encerra
				rank[tostring(x)].pontos = m1.pontos
				break
			end
			
		-- Se o objeto atual for um recolocado
		else
			-- Se for o objeto novo que ja foi colocado
			if rank[tostring(x)].grupo == grupo then
				rank[tostring(x)].grupo = m1.grupo
				rank[tostring(x)].pontos = m1.pontos
				break
				
			-- Se nao for compara normalmente
			else
				if rank[tostring(x)].pontos < m1.pontos then
					-- Substitui posicao
					m2.grupo = rank[tostring(x)].grupo
					m2.pontos = rank[tostring(x)].pontos
					rank[tostring(x)].grupo = m1.grupo
					rank[tostring(x)].pontos = m1.pontos
									
					-- m2 para a ser m1 para a proxima comparacao
					m1.grupo = m2.grupo
					m1.pontos = m2.pontos
				end
			end
			
		end
	end
	manipulus.bd.salvar("Ranking", "pontos", rank)
end

-- Certifica de que rank existe
if manipulus.bd.verif("Ranking", "pontos") == false then
	rank = {
		["1"] = {grupo="Colocado 1",pontos=0},
		["2"] = {grupo="Colocado 2",pontos=0},
		["3"] = {grupo="Colocado 3",pontos=0},
		["4"] = {grupo="Colocado 4",pontos=0},
		["5"] = {grupo="Colocado 5",pontos=0},
		["6"] = {grupo="Colocado 6",pontos=0},
		["7"] = {grupo="Colocado 7",pontos=0},
		["8"] = {grupo="Colocado 8",pontos=0},
		["9"] = {grupo="Colocado 9",pontos=0},
		["10"] = {grupo="Colocado 10",pontos=0},
	}
	manipulus.bd.salvar("Ranking", "pontos", rank)
end

-- Estatisticas Gerais
if manipulus.bd.verif("Estatisticas", "grupos_criados") == false then
	manipulus.bd.salvar("Estatisticas", "grupos_criados", 0)
end

-- Pegar numero de grupos criados
manipulus.get_grupos_criados = function()
	return manipulus.bd.pegar("Estatisticas", "grupos_criados")
end

-- Somar 1 grupo criado
manipulus.add_grupos_criados = function()
	local n = manipulus.bd.pegar("Estatisticas", "grupos_criados")
	return manipulus.bd.salvar("Estatisticas", "grupos_criados", (n+1))
end

-- Estatisticas de grupo
-- Pegar numero de demarcadores
manipulus.get_demarcador_grupo = function(grupo)
	return manipulus.bd.pegar("grupo_"..grupo, "demarcadores")
end

-- Somar 1 ao numero de demarcadores
manipulus.add_demarcador_grupo = function(grupo)
	local n = manipulus.bd.pegar("grupo_"..grupo, "demarcadores")
	return manipulus.bd.salvar("grupo_"..grupo, "demarcadores", (n+1))
end

-- subtrai 1 ao numero de demarcadores
manipulus.rem_demarcador_grupo = function(grupo)
	local n = manipulus.bd.pegar("grupo_"..grupo, "demarcadores")
	return manipulus.bd.salvar("grupo_"..grupo, "demarcadores", (n-1))
end


