--[[
	Mod Manipulus para Minetest
	Copyright (C) 2018 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	API
  ]]

local S = manipulus.Sfake

-- Limite de membros num grupo
local limite_membros_grupo = 30

-- Limite de caracteres do texto descritivo
local limite_chars_descritivo = 300

-- Tabela de strings de textos
manipulus.textos = {
	-- Prefixos de membros
	prefix_fundador = S("Fundador"),
	prefix_lider = S("Lider"),
	-- Alerta de Caracteres
	alerta_caracteres_grupo = S("Apenas palavras com 30 caracteres de A-Z"),
	-- Nome de grupo invalido
	alerta_grupo_invalido = S("Nome de grupo '@1' invalido"),
	-- Alerta de certeza
	alerta_certeza = S("Tenha certeza do que vai fazer"),
	-- Texto sobre abandonar grupo
	abandonar_grupo = S("Ao abandonar @1 voce so vai poder voltar a participar se o recrutamento estiver aberto"),
	-- Texto sobre desfazer grupo
	desfazer_grupo = S("Todos os membros serao retirados e o grupo deixara de existir"),
	-- Texto de aviso sobre limite de caracteres do texto descritivo
	aviso_editar_descritivo_limite = S("Limite de @1 caracteres para textos descritivos"),
	-- Texto de alerta sobre caracteres especiais
	aviso_editar_descritivo_alerta_char = S("Evite usar caracteres especiais devido a possiveis erros de compatibilidade entre diferentes computadores"),
	-- Texto de texto nulo
	aviso_texto_descritivo_nulo = S("Nenhum texto descritivo escrito"),
	-- Texto alerta de nome de grupo ja existente
	aviso_grupo_ja_existente = ("Esse grupo ja existe. Escolha outro nome."),
}

S = manipulus.S

-- Caracteres validos
local valid_chars = {
	-- Maiusculos
	["A"] = true,
	["B"] = true,
	["C"] = true,
	["D"] = true,
	["E"] = true,
	["F"] = true,
	["G"] = true,
	["H"] = true,
	["I"] = true,
	["J"] = true,
	["K"] = true,
	["L"] = true,
	["M"] = true,
	["N"] = true,
	["O"] = true,
	["P"] = true,
	["Q"] = true,
	["R"] = true,
	["S"] = true,
	["T"] = true,
	["U"] = true,
	["V"] = true,
	["W"] = true,
	["X"] = true,
	["Y"] = true,
	["Z"] = true,
	-- Minusculos
	["a"] = true,
	["b"] = true,
	["c"] = true,
	["d"] = true,
	["e"] = true,
	["f"] = true,
	["g"] = true,
	["h"] = true,
	["i"] = true,
	["j"] = true,
	["k"] = true,
	["l"] = true,
	["m"] = true,
	["n"] = true,
	["o"] = true,
	["p"] = true,
	["q"] = true,
	["r"] = true,
	["s"] = true,
	["t"] = true,
	["u"] = true,
	["v"] = true,
	["w"] = true,
	["x"] = true,
	["y"] = true,
	["z"] = true,
	-- Caracteres especiais
	[" "] = true
}

-- Verificar nome do grupo
manipulus.checkname_grupo = function(nome)
	-- Verifica comprimento
	if string.len(nome) > 30 or string.len(nome) == 0 then
		return false, 1
	end
	
	-- Verifica caracteres validos
	local nome_valido = ""
	for char in string.gmatch(nome, ".") do
		if valid_chars[char] then
			nome_valido = nome_valido .. char
		end
	end
	if nome ~= nome_valido then
		return false, 2, nome_valido
	end
	
	return true
end

-- Verificar texto sem caracteres
manipulus.check_text = function(s)
	if s == nil then return false end
	for char in string.gmatch(s, "%a") do
		return true
	end
	return false
end

-- Verificar nome do grupo
manipulus.checkdesc_grupo = function(desc)
	
	-- Verifica caracteres validos
	if manipulus.check_text(desc) == false then
		return false, 1
	end
	
	-- Verifica comprimento
	if string.len(desc) > limite_chars_descritivo then
		return false, 2
	end
	
	return true
end

-- Contar membros
local contar_tb = function(tb)
	local c = 0
	for _,d in pairs(tb) do
		c = c + 1
	end
	return c
end

-- Calcular logomarca de rank
local get_formspec_logo_rank = function(grupo)
	local rank = manipulus.get_rank()
	-- Primeiro lugar
	if grupo == rank["1"].grupo then
		return "background[-2,-1.5;3,3;manipulus_rank1.png]"
	elseif grupo == rank["2"].grupo then
		return "background[-1.5,-1.5;2,2;manipulus_rank2.png]"
	elseif grupo == rank["3"].grupo then
		return "background[-1,-1;1.7,1.5;manipulus_rank3.png]"
	else
		return ""
	end
end

-- Pegar numero do item selecionado no formspec
local get_item_number = function(s)
	return tonumber(string.sub(s, 5))
end

-- Controle de dados do formspec
local get_formspec_data = function(name)
	return minetest.deserialize(minetest.get_player_by_name(name):get_attribute("manipulus_formspec_data"))
end
local set_formspec_data = function(name, data)
	minetest.get_player_by_name(name):set_attribute("manipulus_formspec_data", minetest.serialize(data))
end

-- Acessar menu
manipulus.acessar_menu = function(name, dados)
	if not name then return end
	local player = minetest.get_player_by_name(name)
	local grupo = manipulus.get_player_grupo(name)
	
	-- Atualiza rank com grupo de quem acessa
	if grupo ~= nil then
		manipulus.update_rank(grupo)
	end
	
	-- Redireciona direto para iniciar na pagina do grupo
	if dados == nil and grupo ~= nil then
		dados = {grupo={}}
	end
	
	-- Painel para pesquisa
	if dados == nil or dados.pesquisa then
		
		local formspec_data = get_formspec_data(name)
		if formspec_data == nil then formspec_data = {} end
		
		-- Pesquisa
		local pesquisa = "-"
		if formspec_data and formspec_data.pesquisado then
			pesquisa = formspec_data.pesquisado
		end
		
		local formspec = "size[10,8]"
			..default.gui_bg
			..default.gui_bg_img
			.."label[0,0;"..S("Menu de Grupos").."]"
			
			-- Pesquisa
			.."field[0.3,1.3;8,1;pesquisa;"..S("Pesquisar por Grupo")..";"..pesquisa.."]"
			.."button[8,1;2,1;pesquisar;"..S("Pesquisar").."]"
				
			-- Sair
			.."button_exit[8,0;2,1;sair;"..S("Sair").."]"
		
		-- Resultado da pesquisa
		if dados and dados.pesquisa.formspec then
			formspec = formspec 
				..dados.pesquisa.formspec
				-- Retornar para Ranking
				.."button[6,0;2,1;ranking;"..S("Ranking").."]"
		
		-- Ranking
		else
			local rank = manipulus.get_rank()
			
			-- Imagens
			formspec = formspec .. "background[0.1,2.45;9.5,5;manipulus_fundo_rank.png]"
				.."background[9.1,6.9;0.65,0.65;manipulus_rankn.png]"
				.."background[9.3,6.4;0.65,0.65;manipulus_rankn.png]"
				.."background[9.1,5.9;0.65,0.65;manipulus_rankn.png]"
				.."background[9.3,5.4;0.65,0.65;manipulus_rankn.png]"
				.."background[9.1,4.9;0.65,0.65;manipulus_rankn.png]"
				.."background[9.3,4.4;0.65,0.65;manipulus_rankn.png]"
				.."background[9.1,3.9;0.65,0.65;manipulus_rankn.png]"
				.."background[9,3.3;0.8,0.8;manipulus_rank3.png]"
				.."background[9.2,2.8;0.9,0.9;manipulus_rank2.png]"
				.."background[8.8,2.2;1,1;manipulus_rank1.png]"
				
			formspec = formspec .."label[0.6,1.9;"..S("Pontos").."]".."label[2,1.9;"..S("Grupo").."]"
			for x=1, 10 do
				local w = (1.9+(0.5*x))
				formspec = formspec .."label[0.6,"..w..";"..rank[tostring(x)].pontos.."]"
					.."label[2.1,"..w..";"..rank[tostring(x)].grupo.."]"
				
				if manipulus.existe_grupo(rank[tostring(x)].grupo) == true then
					formspec = formspec .. "image_button[0,"..(w-0.05)..";0.7,0.7;default_book.png;ver_"..x..";]"
				end
			end
			
			-- Salva ranking visualizado
			formspec_data.rank = rank
			set_formspec_data(name, formspec_data)
		end		
		
		-- Botão de Fundar ou sair de grupo
		if grupo == nil then
			formspec = formspec .."button[0,7.3;10,1;fundar_grupo;"..S("Fundar novo grupo").."]"
		else
			formspec = formspec .."button[0,7.3;10,1;meu_grupo;"..grupo.."]"
		end
		
		minetest.show_formspec(name, "manipulus:menu_pesquisa", formspec)
		return
	
	
	-- Fundar um grupo
	elseif dados.fundar then
		
		if dados.fundar.aviso_desc == nil then
			dados.fundar.aviso_desc = S(manipulus.textos.aviso_editar_descritivo_limite, limite_chars_descritivo)
				.."\n"..S(manipulus.textos.aviso_editar_descritivo_alerta_char)
		end
		if dados.fundar.aviso_nome == nil then
			dados.fundar.aviso_nome = S(manipulus.textos.alerta_caracteres_grupo)
		end
		
		-- Texto escrito
		local desc = "-"
		if dados.fundar.descritivo ~= nil and manipulus.check_text(dados.fundar.descritivo) == true then
			desc = dados.fundar.descritivo
		end
		local chat_st = "("..string.len(desc).."/"..limite_chars_descritivo..")"
		
		-- Nome do grupo
		if dados.fundar.nome == nil or dados.fundar.nome == "" then
			dados.fundar.nome = "-"
		end
		
		local formspec = "size[10,8]"
			..default.gui_bg
			..default.gui_bg_img
			.."label[0,0;"..S("Fundar grupo").."]"
			
			-- Nome do Grupo
			.."field[0.3,1.5;10,1;grupo;"..S("Nome do novo grupo").." ("..S("jamais pode alterar")..");"..dados.fundar.nome.."]"
			.."label[0,2;"..dados.fundar.aviso_nome.."]" -- Msg aviso
			
			-- Avisos
			.."textarea[6.3,3.5;4,5;;"..dados.fundar.aviso_desc..";]"
			
			-- Descritivo
			.."textarea[0.3,3.6;6,4;descritivo;"..S("Texto descritivo").." "..chat_st..";"..desc.."]"
			
			-- Finalizar
			.."button[0,7.3;10,1;fundar;"..S("Fundar").."]"
		
		minetest.show_formspec(name, "manipulus:menu_fundar", formspec)
		return
	
	
	-- Menu do Grupo
	elseif dados.grupo then
		
		local dados_grupo = manipulus.get_grupo(grupo)
		
		local formspec_data = get_formspec_data(name)
		if formspec_data == nil then formspec_data = {} end
		-- Lista de membros
		local membros = ""
		local membro_selecionado = ""
		local cargo_membro_selecionado = "membro"
		local i = 0
		formspec_data.membros = {}
		for n,d in pairs(dados_grupo.membros) do
			i = i + 1
			table.insert(formspec_data.membros, n)
			local prefix = ""
			-- Fundador
			if n == dados_grupo.fundador then
				prefix = "Fundador"
			-- Lider
			elseif dados_grupo.lideres[n] ~= nil then
				prefix = "Lider"
			end
			if membros ~= "" then membros = membros .. "," end
			if prefix ~= "" then
				membros = membros .. "("..S(prefix)..") "..n
			else
				membros = membros ..n
			end
			if formspec_data.membro ~= nil and formspec_data.membro == n then
				membro_selecionado = tostring(i)
				if prefix == "Fundador" then
					cargo_membro_selecionado = "fundador"
				elseif  prefix == "Lider" then
					cargo_membro_selecionado = "lider"
				end
			end
		end
		set_formspec_data(name, formspec_data)
		
		-- Mensagem Padrao
		if dados.grupo.msg == nil then
			dados.grupo.msg = ""
		end
		
		-- Botao de lideres
		local botao_lider_text = S("Tornar Lider")
		local botao_lider_name = "tornar_lider"
		if cargo_membro_selecionado == "lider" then
			botao_lider_text = S("Desfazer Lider")
			botao_lider_name = "desfazer_lider"
		end
		
		-- Status de recrutamento
		local status_recrutamento = "false"
		if dados_grupo.recrutamento == true then
			status_recrutamento = "true"
		end
		
		-- Painel de fundador
		if name == dados_grupo.fundador then
			
			local formspec = "size[10,8]"
				..get_formspec_logo_rank(grupo)
				..default.gui_bg
				..default.gui_bg_img
				.."label[0.17,0;"..grupo.."\n"..dados_grupo.pontos.." "..S("pontos").."]"
				
				-- Sair
				.."button_exit[7.9,0;2,1;sair;"..S("Sair").."]"
				-- Pesquisar
				.."button[5.5,0;2.4,1;pesquisar;"..S("Ranking").."]"
				
				-- Descritivo
				.."label[0.17,1;"..S("Descritivo").."]"
				.."textarea[0.4,1.5;5.3,5.5;;"..dados_grupo.descritivo..";]"
				.."button[3.34,0.8;2,1;editar_descritivo;"..S("Editar").."]"
				
				-- Abandonar
				.."button[0.1,6.2;5.3,1;abandonar;"..S("Desfazer").."]"
				
				-- Lista de membros
				.."label[5.5,1;"..S("Membros").." ("..tostring(dados_grupo.qtd_membros)..")]"
				.."textlist[5.5,1.5;4.2,2.5;membros;"..membros..";"..membro_selecionado..";false]"
				.."checkbox[5.5,3.9;recrutamento;"..S("Recrutamento")..";"..status_recrutamento.."]"
				.."button[5.5,4.6;4.4,1;"..botao_lider_name..";"..botao_lider_text.."]"
				.."button[5.5,5.4;4.4,1;tornar_fundador;"..S("Tornar fundador").."]"
				.."button[5.5,6.2;4.4,1;expulsar;"..S("Expulsar").."]"
				
				-- Alerta
				.."textarea[0.4,7.1;9.85,1.2;;"..dados.grupo.msg..";]"
				
			minetest.show_formspec(name, "manipulus:menu_grupo", formspec)
			return
		
		-- Painel de Lider
		elseif dados_grupo.lideres[name] ~= nil then
			
			local formspec = "size[10,8]"
				..get_formspec_logo_rank(grupo)
				..default.gui_bg
				..default.gui_bg_img
				.."label[0.17,0;"..grupo.."\n"..dados_grupo.pontos.." "..S("pontos").."]"
				
				-- Sair
				.."button_exit[7.9,0;2,1;sair;"..S("Sair").."]"
				-- Pesquisar
				.."button[5.5,0;2.4,1;pesquisar;"..S("Ranking").."]"
				
				-- Descritivo
				.."label[0.17,1;"..S("Descritivo").."]"
				.."textarea[0.4,1.5;5.3,5.5;;"..dados_grupo.descritivo..";]"
				.."button[3.34,0.8;2,1;editar_descritivo;"..S("Editar").."]"
				
				-- Abandonar
				.."button[0.1,6.2;5.3,1;abandonar;"..S("Desfazer").."]"
				
				-- Lista de membros
				.."label[5.5,1;Membros ("..tostring(dados_grupo.qtd_membros)..")]"
				.."textlist[5.5,1.5;4.2,3.2;membros;"..membros..";"..membro_selecionado..";false]"
				.."checkbox[5.5,4.6;recrutamento;"..S("Recrutamento")..";"..status_recrutamento.."]"
				.."button[5.5,5.4;4.4,1;deixar_lider;"..S("Deixar de ser lider").."]"
				.."button[5.5,6.2;4.4,1;expulsar;"..S("Expulsar").."]"
				
				-- Alerta
				.."textarea[0.4,7.1;9.85,1.2;;"..dados.grupo.msg..";]"
			
			minetest.show_formspec(name, "manipulus:menu_grupo", formspec)
			return
		
		-- Painel de membro
		else
			local formspec = "size[10,8]"
				..get_formspec_logo_rank(grupo)
				..default.gui_bg
				..default.gui_bg_img
				.."label[0.17,0;"..grupo.."\n"..dados_grupo.pontos.." "..S("pontos").."]"
				
				-- Sair
				.."button_exit[7.9,0;2,1;sair;"..S("Sair").."]"
				-- Pesquisar
				.."button[5.5,0;2.4,1;pesquisar;"..S("Ranking").."]"
				
				-- Descritivo
				.."label[0.17,1;"..S("Descritivo").."]"
				.."textarea[0.4,1.5;5.3,6.5;;"..dados_grupo.descritivo..";]"
				
				-- Abandonar
				.."button[0.1,7.2;5.3,1;abandonar;"..S("Abandonar").."]"
				
				-- Lista de membros
				.."label[5.5,1;Membros ("..tostring(dados_grupo.qtd_membros)..")]"
				.."textlist[5.5,1.5;4.2,6.5;membros;"..membros..";"..membro_selecionado..";false]"
				
			minetest.show_formspec(name, "manipulus:menu_grupo", formspec)
			return
		
		end
	
	-- Confirmar abandono
	elseif dados.abandonar then
		
		local formspec = "size[10,8]"
			..get_formspec_logo_rank(grupo)
			..default.gui_bg
			..default.gui_bg_img
			.."label[0,0;"..S("Abandonar @1", grupo).."]"
			
			.."label[2,5;"..S(manipulus.textos.alerta_certeza).."]"
			-- Cancelar
			.."button[2,6.3;6,1;cancelar;"..S("Cancelar").."]"
		
		-- Texto para fundadores
		if dados.abandonar.fundador == true then
		
			formspec = formspec
				-- Descritivo
				.."textarea[0.4,0.6;9.8,5;;"..S(manipulus.textos.abandonar_grupo, grupo)..";]"
				
				-- Abandonar
				.."button[2,5.3;6,1;abandonar;"..S("Desfazer").."]"
			
		-- Texto para membros e lideres
		else
			formspec = formspec
				-- Descritivo
				.."textarea[0.4,0.6;9.8,5;;"..S(manipulus.textos.desfazer_grupo)..";]"
				
				-- Abandonar
				.."button[2,5.3;6,1;abandonar;"..S("Abandonar").."]"
			
		end
		
		minetest.show_formspec(name, "manipulus:abandonar", formspec)
		return
		
	elseif dados.deixar_lider then
		
		local formspec = "size[10,8]"
			..get_formspec_logo_rank(grupo)
			..default.gui_bg
			..default.gui_bg_img
			.."label[0,0;"..S("Deixar de ser lider").."]"
			
			-- Descritivo
			.."textarea[1,1;8,5;;"..S("Tem certeza")..";]"
			
			-- Abandonar
			.."button[2,5.3;6,1;deixar_lider;"..S("Deixar de ser lider").."]"
			
			-- Cancelar
			.."button[2,6.3;6,1;cancelar;"..S("Cancelar").."]"
		
		minetest.show_formspec(name, "manipulus:deixar_lider", formspec)
		return
	
	elseif dados.tornar_fundador then
		
		local formspec = "size[10,8]"
			..get_formspec_logo_rank(grupo)
			..default.gui_bg
			..default.gui_bg_img
			.."label[0,0;"..S("Tornar fundador").."]"
			
			-- Descritivo
			.."textarea[1,1;8,5;;"..S("Tem certeza")..";]"
			
			-- Abandonar
			.."button[2,5.3;6,1;tornar_fundador;"..S("Tornar fundador").."]"
			
			-- Cancelar
			.."button[2,6.3;6,1;cancelar;"..S("Cancelar").."]"
		
		minetest.show_formspec(name, "manipulus:tornar_fundador", formspec)
		return
		
	elseif dados.editar_descritivo then
		
		if dados.editar_descritivo.msg == nil then
			dados.editar_descritivo.msg = ""
		end
		
		local chat_st = "("..string.len(dados.editar_descritivo.descritivo).."/"..limite_chars_descritivo..")"
		
		local formspec = "size[10,8]"
			..get_formspec_logo_rank(grupo)
			..default.gui_bg
			..default.gui_bg_img
			.."label[0,0;"..S("Editar texto descritivo").."]"
			
			-- Avisos
			.."textarea[0.4,0.6;9.8,2.2;;"..S(manipulus.textos.aviso_editar_descritivo_limite, limite_chars_descritivo)
				.."\n"..S(manipulus.textos.aviso_editar_descritivo_alerta_char)..";]"
			
			-- Texto
			.."textarea[0.3,3;6,5;texto;"..S("Texto descritivo").." "..chat_st..";"..dados.editar_descritivo.descritivo.."]"
			
			-- Cancelar
			.."button[0,7.4;5,1;confirmar;"..S("Confirmar").."]"
			.."button[5,7.4;5,1;cancelar;"..S("Cancelar").."]"
			
			.."textarea[6.3,3;4,5;;"..dados.editar_descritivo.msg..";]"
		
		minetest.show_formspec(name, "manipulus:editar_descritivo", formspec)
		return
	end
	
end

-- Receptor de retornos do menu
manipulus.register_on_player_receive_fields = function(player, formname, fields)
	
	if formname == "manipulus:menu_pesquisa" then
		
		local name = player:get_player_name()
		local formspec_data = get_formspec_data(name)
		
		-- Fechar formspec
		if fields.quit then
			set_formspec_data(player:get_player_name(), nil)
			return
		end
		
		-- Ver do rank
		for x=1, 10 do
			if fields["ver_"..x] then
				local grupo = formspec_data.rank[tostring(x)].grupo
				-- Encaminha para efeito de pesquisa comum
				fields.pesquisar = true
				fields.pesquisa = grupo
			end
		end
		
		-- Ver Ranking
		if fields.ranking then
			manipulus.acessar_menu(name, {pesquisa={}})
			return
		end
		
		-- Pesquisar
		if fields.pesquisar then
			local dados = {pesquisa={}}
			
			-- Salva grupo pesquisado
			if formspec_data == nil then formspec_data = {}	end
			formspec_data.pesquisado = fields.pesquisa
			set_formspec_data(name, formspec_data)
			
			-- Verifica se digitou um nome
			if fields.pesquisa == "" then
				manipulus.acessar_menu(name)
				return
			end
			
			-- Verifica se nome é valido [desenvolver verificacao]
			if manipulus.checkname_grupo(fields.pesquisa) == false then
				dados.pesquisa.formspec = "textarea[1,3;8,5;;"..S("Nome '@1' invalido", fields.pesquisa)..".\n"..S(manipulus.textos.alerta_caracteres_grupo)..";]"
				manipulus.acessar_menu(name, dados)
				return
			end
			
			-- Verifica se grupo existe
			if manipulus.existe_grupo(fields.pesquisa) == false then
				dados.pesquisa.formspec = "textarea[1,3;8,5;;"..S("Grupo '@1' inexistente", fields.pesquisa)..";]"
				manipulus.acessar_menu(name, dados)
				return
			end
			
			-- Monta painel do grupo pesquisado
			local dados_grupo = manipulus.get_grupo(fields.pesquisa)
			
			-- Lista de membros
			local membros = ""
			for n,d in pairs(dados_grupo.membros) do
				-- Fundador
				if n == dados_grupo.fundador then
					n = "("..S("Fundador")..") "..n
				end
				-- Lider
				if dados_grupo.lideres[n] ~= nil then
					n = "("..S("Lider")..") "..n
				end
				if membros ~= "" then membros = membros .. "," end
				membros = membros .. n
			end
			
			dados.pesquisa.formspec = "label[0,2;"..fields.pesquisa.."\n"..dados_grupo.pontos.." "..S("pontos").."]"
				
				-- Logo de rank atraz do fundo
				..get_formspec_logo_rank(fields.pesquisa)
				..default.gui_bg
				..default.gui_bg_img
				
				-- Descritivo
				.."label[0.1,3;"..S("Descritivo").."]"
				.."textarea[0.3,3.5;5.5,4.2;;"..dados_grupo.descritivo..";]"
				
				-- Lista de membros
				.."label[5.5,2;"..S("Membros").." ("..dados_grupo.qtd_membros..")]"
				.."textlist[5.5,2.5;4.2,3.5;membros;"..membros..";;false]"
				
			-- Botao de participar
			if dados_grupo.qtd_membros >= limite_membros_grupo then
				dados.pesquisa.formspec = dados.pesquisa.formspec
					.."label[5.5,6.2;"..S("Grupo lotado").."]"
			elseif manipulus.get_player_grupo(name) == nil then
				if dados_grupo.recrutamento == true then
					dados.pesquisa.formspec = dados.pesquisa.formspec
						.."button[5.5,6.2;4.4,1;participar;"..S("Participar").."]"
				else
					dados.pesquisa.formspec = dados.pesquisa.formspec
						.."textarea[5.75,6.2;4.5,1.1;;"..S("Recrutamento fechado")..";]"
				end
			else
				if dados_grupo.recrutamento == true then
					dados.pesquisa.formspec = dados.pesquisa.formspec
						.."textarea[5.75,6.2;4.5,1.1;;"..S("Recrutamento aberto")..";]"
				else
					dados.pesquisa.formspec = dados.pesquisa.formspec
						.."textarea[5.75,6.2;4.5,1.1;;"..S("Recrutamento fechado")..";]"
				end
			end
			manipulus.acessar_menu(name, dados)
			return
		
		elseif fields.fundar_grupo then
			local dados = {fundar={}}
			
			-- Aviso inicial
			dados.fundar.aviso_nome = S(manipulus.textos.alerta_caracteres_grupo)
			
			manipulus.acessar_menu(name, dados)
			return
		
		-- Participar
		elseif fields.participar and formspec_data ~= nil and formspec_data.pesquisado ~= nil then
			local dados = {pesquisa={}}
			
			-- Verifica se grupo existe
			local dados_grupo = manipulus.get_grupo(formspec_data.pesquisado)
			if dados_grupo == nil then
				dados.pesquisa.formspec = "textarea[1,3;8,5;;"..S("Grupo '@1' inexistente", formspec_data.pesquisado)..";]"
				manipulus.acessar_menu(name, dados)
				return
			end
			-- Verifica se o recrutamento esta aberto 
			if dados_grupo.recrutamento == false then
				dados.pesquisa.formspec = "textarea[1,3;8,5;;"..S("Recrutamento fechado para @1", formspec_data.pesquisado)..";]"
				manipulus.acessar_menu(name, dados)
				return
			end
			-- Verifica limite de membros
			if dados_grupo.qtd_membros >= limite_membros_grupo then
				dados.pesquisa.formspec = "textarea[1,3;8,5;;"..S("Grupo '@1' lotado", formspec_data.pesquisado)..";]"
				manipulus.acessar_menu(name, dados)
				return
			end
			
			-- Adicionar membro
			manipulus.add_membro(formspec_data.pesquisado, name)
			manipulus.acessar_menu(name)
			return
			
		elseif fields.meu_grupo then
			manipulus.acessar_menu(name)
			return
		end
		
	
	elseif formname == "manipulus:menu_fundar" then
		
		-- Fechar formspec
		if fields.quit then
			set_formspec_data(player:get_player_name(), nil)
			return
		end
		
		if fields.fundar then
			local name = player:get_player_name()
			local dados = {fundar={}}
			dados.fundar.descritivo = fields.descritivo
			dados.fundar.nome = fields.grupo
			
			-- Verificar nome valido
			if manipulus.checkname_grupo(fields.grupo) == false then
				dados.fundar.aviso_nome = S(manipulus.textos.alerta_caracteres_grupo)
				manipulus.acessar_menu(name, dados)
				return
			end
			
			-- Verificar se o grupo ja existe
			local checkname, erro, nome_valido = manipulus.existe_grupo(fields.grupo)
			if checkname == true then
				dados.fundar.aviso_nome = S(manipulus.textos.aviso_grupo_ja_existente)
				if nome_valido ~= nil then
					dados.fundar.nome = nome_valido
				end
				manipulus.acessar_menu(name, dados)
				return
			end
			
			-- Verificar descritivo
			local checkdesc, erro = manipulus.checkdesc_grupo(fields.descritivo)
			if checkdesc == false and erro == 1 then -- Texto pequeno
				dados.fundar.aviso_desc = S(manipulus.textos.aviso_texto_descritivo_nulo)
				manipulus.acessar_menu(name, dados)
				return
			end
			if checkdesc == false and erro == 2 then -- Texto grande
				dados.fundar.aviso_desc = S(manipulus.textos.aviso_editar_descritivo_limite, limite_chars_descritivo)
					.."\n"..S(manipulus.textos.aviso_editar_descritivo_alerta_char)
				manipulus.acessar_menu(name, dados)
				return
			end
			
			local def = {}
			
			def.descritivo = fields.descritivo
			
			-- Cria grupo
			manipulus.criar_grupo(fields.grupo, def, name)
			
			manipulus.acessar_menu(name)
			return
		end
		
	elseif formname == "manipulus:menu_grupo" then
		
		local name = player:get_player_name()
		local dados = {grupo={}}
		
		--
		-- Opções gerais
		--
		
		-- Fechar formspec
		if fields.quit then
			set_formspec_data(name, nil)
			return
		end
		
		-- Selecionar membro da lista
		if fields.membros then
			local formspec_data = get_formspec_data(name)
			formspec_data.membro = formspec_data.membros[get_item_number(fields.membros)]
			set_formspec_data(name, formspec_data)
			dados.grupo.msg = S("Membro '@1' selecionado", formspec_data.membro)
			manipulus.acessar_menu(name, dados)
			return
		end
		
		-- Alternar para Pesquisa
		if fields.pesquisar then
			
			manipulus.acessar_menu(name, {pesquisa={}})
			return
		end
		
		--
		-- Opções para membros
		--
		local grupo = manipulus.get_player_grupo(name)
		-- Verifica se é membro (se é membro, é pq o grupo existe)
		if grupo == nil then
			manipulus.acessar_menu(name)
			return
		end
		local dados_grupo = manipulus.get_grupo(grupo)
		
		-- Abandonar/Desfazer grupo
		if fields.abandonar then
			dados = {abandonar={}}
			
			-- Verifica se é fundador
			if name == dados_grupo.fundador then
				dados.abandonar.fundador = true
			end
			
			manipulus.acessar_menu(name, dados)
			return
		end
		
		--
		-- Opções de lideres
		--
		-- Verifica se é lider ou fundador
		if dados_grupo.lideres[name] == nil and dados_grupo.fundador ~= name then
			dados.grupo.msg = S("Precisar ser lider ou fundador para realizar isso")
			manipulus.acessar_menu(name, dados)
			return
		end
		
		-- Deixar de ser lider
		if fields.deixar_lider then
			manipulus.acessar_menu(name, {deixar_lider={}})
			return
		end
		
		-- Tornar Expulsar
		if fields.expulsar then
			local membro = get_formspec_data(name).membro
			if membro == nil then -- Verifica seleção
				dados.grupo.msg = S("Selecione um membro da lista")
				manipulus.acessar_menu(name, dados)
				return
			end
			-- Verifica se expulso ainda é membro
			if manipulus.existe_membro(grupo, membro) == false then
				dados.grupo.msg = S("Jogador '@1' saiu do grupo", membro)
				manipulus.acessar_menu(name, dados)
				return
			end
			-- Verifica se expulso é si mesmo
			if membro == name then
				dados.grupo.msg = S("Nao podes expulsar a si mesmo")
				manipulus.acessar_menu(name, dados)
				return
			end
			-- Verifica se expulso é o fundador
			if membro == dados_grupo.fundador then
				dados.grupo.msg = "Nao podes expulsar o fundador"
				manipulus.acessar_menu(name, dados)
				return
			end
			-- Verifica se expulso é um lider
			if dados_grupo.lideres[membro] ~= nil and name ~= dados_grupo.fundador then
				dados.grupo.msg = S("Apenas o fundador pode expulsar lideres")
				manipulus.acessar_menu(name, dados)
				return
			end
			
			-- Expulsa membro
			manipulus.rem_membro(grupo, membro)
			
			dados.grupo.msg = S("Jogador '@1' foi expulso", membro)
			manipulus.acessar_menu(name, dados)
			return
		end
		
		-- Alterar status de recrutamento
		if fields.recrutamento then
			if fields.recrutamento == "true" then
				manipulus.bd.salvar("grupo_"..grupo, "recrutamento", true)
				dados.grupo.msg = S("Recrutamento aberto").."\n"..S("Agora qualquer jogador pode participar do grupo")
			else
				manipulus.bd.salvar("grupo_"..grupo, "recrutamento", false)
				dados.grupo.msg = S("Recrutamento fechado").."\n"..S("Agora nenhum jogador pode participar do grupo")
			end
			manipulus.acessar_menu(name, dados)
			return
		end
		
		--
		-- Opções de fundador
		--
		if name ~= dados_grupo.fundador then
			dados.grupo.msg = S("Apenas o fundador pode realizar isso")
			manipulus.acessar_menu(name, dados)
			return
		end
		
		-- Editar texto descritivo
		if fields.editar_descritivo then
			dados = {
				editar_descritivo = {
					descritivo = dados_grupo.descritivo
				}
			}
			manipulus.acessar_menu(name, dados)
			return
			
		end
		
		-- Tornar lider
		if fields.tornar_lider then
			local membro = get_formspec_data(name).membro
			if membro == nil then -- Verifica seleção
				dados.grupo.msg = S("Selecione um membro da lista")
				manipulus.acessar_menu(name, dados)
				return
			end
			
			-- Verifica se promovido ainda é membro
			if manipulus.existe_membro(grupo, membro) == false then
				dados.grupo.msg = S("Jogador '@1' saiu do grupo", membro)
				manipulus.acessar_menu(name, dados)
				return
			end
			-- Verifica se vai tornar a si mesmo
			if membro == name then
				dados.grupo.msg = S("Nao podes tornar lider a si mesmo")
				manipulus.acessar_menu(name, dados)
				return
			end
			-- Verifica se ja e lider
			if dados_grupo.lideres[membro] ~= nil then
				dados.grupo.msg = S("Membro '@1' ja e lider", membro)
				manipulus.acessar_menu(name, dados)
				return
			end
			
			manipulus.add_lider(grupo, membro)
			dados.grupo.msg = S("Membro '@1' foi promovido a lider", membro)
			manipulus.acessar_menu(name, dados)
			return
		end
		
		-- Desfazer lider
		if fields.desfazer_lider then
			local membro = get_formspec_data(name).membro
			if membro == nil then -- Verifica seleção
				dados.grupo.msg = S("Selecione um membro da lista")
				manipulus.acessar_menu(name, dados)
				return
			end
			
			-- Verifica se vai tornar a si mesmo
			if membro == name then
				dados.grupo.msg = S("Nao podes desfazerse de ser lider")
				manipulus.acessar_menu(name, dados)
				return
			end
			-- Verifica se ja e lider
			if dados_grupo.lideres[membro] == nil then
				dados.grupo.msg = S("Membro '@1' ja deixou lider", membro)
				manipulus.acessar_menu(name, dados)
				return
			end
			
			manipulus.rem_lider(grupo, membro)
			dados.grupo.msg = S("Membro '@1' deixou de ser lider", membro)
			manipulus.acessar_menu(name, dados)
			return
		end
		
		-- Tornar Fundador
		if fields.tornar_fundador then
			local membro = get_formspec_data(name).membro
			if dados_grupo.fundador == membro then -- Verifica seleção
				dados.grupo.msg = S("Ja es o atual fundador")
				manipulus.acessar_menu(name, dados)
				return
			end
			manipulus.acessar_menu(name, {tornar_fundador={}})
			return
		end
		
	elseif formname == "manipulus:abandonar" then
		
		if fields.abandonar then
			local name = player:get_player_name()
			
			local grupo = manipulus.get_player_grupo(name)
			
			-- Verifica se grupo existe e é membro
			if grupo then
				manipulus.rem_membro(grupo, name)
			end
			
			manipulus.acessar_menu(name)
			return
			
		elseif fields.cancelar then
			local name = player:get_player_name()
			manipulus.acessar_menu(name)
			return
		end
	
	
	elseif formname == "manipulus:deixar_lider" then
		
		if fields.deixar_lider then
			local name = player:get_player_name()
			local grupo = manipulus.get_player_grupo(name)
			
			-- Verifica se grupo existe e é membro
			if grupo == nil then
				manipulus.acessar_menu(name)
				return
			end
			
			local dados_grupo = manipulus.get_grupo(grupo)
			
			-- Verifica se ainda é lider
			if dados_grupo.lideres[name] == nil then
				manipulus.acessar_menu(name)
				return
			end
			
			manipulus.rem_lider(grupo, name)
			manipulus.acessar_menu(name)
			return
			
		elseif fields.cancelar then
			local name = player:get_player_name()
			manipulus.acessar_menu(name)
			return
		end
		
	elseif formname == "manipulus:tornar_fundador" then
		
		local dados = {grupo={}}
		
		if fields.tornar_fundador then
			local name = player:get_player_name()
			local grupo = manipulus.get_player_grupo(name)
			
			local membro = get_formspec_data(name).membro
			if membro == nil then -- Verifica seleção
				dados.grupo.msg = S("Selecione um membro da lista")
				manipulus.acessar_menu(name, dados)
				return
			end
			
			-- Verifica se grupo existe e é membro
			if grupo == nil then
				manipulus.acessar_menu(name)
				return
			end
			
			local dados_grupo = manipulus.get_grupo(grupo)
			
			-- Verifica se ainda é o fundador
			if dados_grupo.fundador ~= name then
				manipulus.acessar_menu(name)
				return
			end
			
			-- Alterna o fundador
			if dados_grupo.lideres[membro] ~= nil then
				manipulus.rem_lider(grupo, membro)
			end
			manipulus.bd.salvar("grupo_"..grupo, "fundador", membro)
			manipulus.add_lider(grupo, name)
			
			manipulus.acessar_menu(name)
			return
			
		elseif fields.cancelar then
			local name = player:get_player_name()
			manipulus.acessar_menu(name)
			return
		end
		
	elseif formname == "manipulus:editar_descritivo" then
		
		if fields.confirmar then
			local name = player:get_player_name()
			local grupo = manipulus.get_player_grupo(name)
			local dados = {}
			
			-- Verifica se grupo existe e é membro
			if grupo == nil then
				manipulus.acessar_menu(name)
				return
			end
			-- Avalia descritivo
			local r, erro = manipulus.checkdesc_grupo(fields.texto)
			
			-- Verificar se tem algum texto
			if r == false and erro == 1 then
				dados = {
					editar_descritivo = {
						descritivo = manipulus.bd.pegar_texto("grupo_"..grupo, "descritivo"),
						msg = S("Nenhum texto escrito"),
					}
				}
				manipulus.acessar_menu(name, dados)
				return
			end
			
			-- Verificar limite de caracteres
			if r == false and erro == 2 then
				dados = {
					editar_descritivo = {
						descritivo = fields.texto,
						msg = S("Limite de @1 caracteres excedido", limite_chars_descritivo),
					}
				}
				manipulus.acessar_menu(name, dados)
				return
			end
			
			local dados_grupo = manipulus.get_grupo(grupo)
			
			-- Verifica se ainda é fundador
			if dados_grupo.fundador ~= name then
				manipulus.acessar_menu(name)
				return
			end
			
			manipulus.bd.salvar_texto("grupo_"..grupo, "descritivo", fields.texto)
			
			manipulus.acessar_menu(name, {grupo={msg=S("Texto descritivo editado")}})
			return
			
		elseif fields.cancelar then
			local name = player:get_player_name()
			manipulus.acessar_menu(name)
			return
		end
	end
end
minetest.register_on_player_receive_fields(manipulus.register_on_player_receive_fields)

-- Comando basico
minetest.register_chatcommand("grupo", {
	description = "Abrir painel de grupos",
	privs = {},
	func = function(name)
		manipulus.acessar_menu(name)
	end,
})

-- Registrar guia iniciam em sfinv
if sfinv then
	sfinv.register_page("manipulus:grupo", {
		title = S("Grupo"),
		get = function(self, player, context)
			local formspec = "label[0,0;"..S("Menu de Grupos").."]"
				.."label[0,0.5;"..S("Ranking").."]"
				.."button[6,0;2,1;pesquisar;"..S("Pesquisar").."]"
			
			-- Ranking
			local rank = manipulus.get_rank()
			-- Imagens
			formspec = formspec .. "background[0.1,1.45;7.5,1.5;manipulus_fundo_rank_inv.png]"
				.."background[7,2.3;0.8,0.8;manipulus_rank3.png]"
				.."background[7.2,1.8;0.9,0.9;manipulus_rank2.png]"
				.."background[6.8,1.2;1,1;manipulus_rank1.png]"
			formspec = formspec .."label[0.6,0.9;"..S("Pontos").."]".."label[2,0.9;"..S("Grupo").."]"
			for x=1, 3 do
				local w = (0.9+(0.5*x))
				formspec = formspec .."label[0.6,"..w..";"..rank[tostring(x)].pontos.."]"
					.."label[2.1,"..w..";"..rank[tostring(x)].grupo.."]"
				
				if manipulus.existe_grupo(rank[tostring(x)].grupo) == true then
					formspec = formspec .. "image_button[0,"..(w-0.05)..";0.7,0.7;default_book.png;ver_"..x..";]"
				end
			end
			
			-- Acessar proprio grupo
			local grupo = manipulus.get_player_grupo(player:get_player_name())
			if grupo ~= nil then
				formspec = formspec.."button[0,3.7;8,1;grupo;"..grupo.."]"
			end
			
			return sfinv.make_formspec(player, context, formspec, true)
		end,
		on_player_receive_fields = function(self, player, context, fields)
			if fields.grupo then
				if manipulus.get_player_grupo(player:get_player_name()) ~= nil then
					manipulus.acessar_menu(player:get_player_name(), {grupo={}})
					return 
				else
					manipulus.acessar_menu(player:get_player_name(), {pesquisa={}})
					return
				end
			elseif fields.pesquisar then
				manipulus.acessar_menu(player:get_player_name(), {pesquisa={}})
				return 
			end
			for x=1, 3 do
				if fields["ver_"..x] then
					local grupo = manipulus.get_rank()[tostring(x)].grupo
					-- Encaminha para efeito de pesquisa comum
					if manipulus.existe_grupo(grupo) == true then
						return manipulus.register_on_player_receive_fields(
							player, 
							"manipulus:menu_pesquisa", 
							{pesquisa=grupo, pesquisar = true}
						)
					end
					manipulus.acessar_menu(player:get_player_name(), {pesquisa={}})
					return 
				end
			end
		end,
	})
end

