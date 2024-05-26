AddTechBranch("MYST", 2)

AddRecipeTab("BOOKS", 999, "images/hud.xml", "tab_book.tex")

--[[
--Recipes
--]]

--Mortar and Pestle
local recipe_grinder = Recipe("grinder", {Ingredient("log"), Ingredient("rocks")}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
recipe_grinder.atlas = resolvefilepath("images/grinder.xml")
recipe_grinder.image = "grinder.tex"

local ink_ingredients = {Ingredient("pinecone_ground", 2, "images/pinecone_ground.xml")}
if IsDLCEnabled(CAPY_DLC) then
	table.insert(ink_ingredients,Ingredient("coconut_ground", 2, "images/coconut_ground.xml"))
end
if IsDLCEnabled(CAPY_DLC) or IsDLCEnabled(REIGN_OF_GIANTS) then
	table.insert(ink_ingredients,Ingredient("acorn_ground", 2, "images/acorn_ground.xml"))
end

--Ink
local recipe_ink = Recipe("ink", {Ingredient("gumarabic_ground", 2, "images/gumarabic_ground.xml"), VariableIngredient(ink_ingredients), Ingredient("nightmarefuel", 2)}, RECIPETABS.BOOKS, TECH.MAGIC_TWO, RECIPE_GAME_TYPE.VANILLA)
recipe_ink.atlas = resolvefilepath("images/ink.xml")
recipe_ink.image = "ink.tex"

--Quill
local recipe_quill = Recipe("quill", {VariableIngredient({Ingredient("feather_crow", 1),Ingredient("feather_robin", 1),Ingredient("feather_robin_winter", 1)}), Ingredient("ink", 1, "images/ink.xml")}, RECIPETABS.BOOKS, TECH.SCIENCE_ONE)
recipe_quill.atlas = resolvefilepath("images/quill.xml")
recipe_quill.image = "quill.tex"

--Writing Desk
local recipe_writingdesk = Recipe("writingdesk", {Ingredient("boards", 4)}, RECIPETABS.BOOKS, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.COMMON, "writingdesk_placer")
recipe_writingdesk.atlas = resolvefilepath("images/writingdesk.xml")
recipe_writingdesk.image = "writingdesk.tex"

--Linking Panel
local recipe_linkpanel = Recipe("linkpanel", {Ingredient("papyrus", 1), Ingredient("ink", 1, "images/ink.xml")}, RECIPETABS.BOOKS, TECH.MYST_2)
recipe_linkpanel.atlas = resolvefilepath("images/linkpanel.xml")
recipe_linkpanel.image = "linkpanel.tex"

--Descriptive Book
local recipe_worldbook = Recipe("worldbook", {Ingredient("pigskin", 2), Ingredient("papyrus", 8), Ingredient("linkpanel", 1, "images/linkpanel.xml")}, RECIPETABS.BOOKS, TECH.MYST_2)
recipe_worldbook.atlas = resolvefilepath("images/worldbook.xml")
recipe_worldbook.image = "worldbook.tex"

--Linking Book
local recipe_linkbook = Recipe("linkbook", {Ingredient("pigskin", 2), Ingredient("papyrus", 4), Ingredient("linkpanel", 1, "images/linkpanel.xml")}, RECIPETABS.BOOKS, TECH.MYST_2)
recipe_linkbook.atlas = resolvefilepath("images/linkbook.xml")
recipe_linkbook.image = "linkbook.tex"