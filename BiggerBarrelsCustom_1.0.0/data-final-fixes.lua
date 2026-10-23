
-- BiggerBarrelsCustom
-- Factorio 2.1
-- MOD設定で指定した液体量を充填・排出レシピに適用する

local target_amount =
    settings.startup["BiggerBarrelsCustom-fluid-amount"].value

local changed_fill = 0
local changed_empty = 0

-- 液体量を設定値に変更する
local function change_fluid_amount(entries)
    local changed = false

    if not entries then
        return false
    end

    for _, entry in pairs(entries) do
        if entry.type == "fluid" and entry.amount == 50 then
            entry.amount = target_amount
            changed = true
        end
    end

    return changed
end

for name, recipe in pairs(data.raw.recipe) do
    -- 排出レシピ：empty-water-barrel など
    if name:match("^empty%-.+%-barrel$") then
        local changed = false

        if change_fluid_amount(recipe.ingredients) then
            changed = true
        end

        if change_fluid_amount(recipe.results) then
            changed = true
        end

        if changed then
            changed_empty = changed_empty + 1
            log(
                "[BiggerBarrelsCustom] Empty recipe changed: "
                .. name
                .. " -> "
                .. target_amount
            )
        end

    else
        -- 充填レシピ：water-barrel など
        local ingredients = recipe.ingredients or {}
        local results = recipe.results or {}

        -- 単一result形式にも対応
        if #results == 0 and recipe.result then
            results = {
                {
                    type = "item",
                    name = recipe.result,
                    amount = recipe.result_count or 1
                }
            }
        end

        local makes_barrel = false

        for _, result in pairs(results) do
            if result.name
                and result.name:find("barrel", 1, true)
                and (result.type == nil or result.type == "item") then
                makes_barrel = true
                break
            end
        end

        if makes_barrel and change_fluid_amount(ingredients) then
            changed_fill = changed_fill + 1
            log(
                "[BiggerBarrelsCustom] Fill recipe changed: "
                .. name
                .. " -> "
                .. target_amount
            )
        end
    end
end

log(
    "[BiggerBarrelsCustom] Target fluid amount: "
    .. target_amount
)

log(
    "[BiggerBarrelsCustom] Changed fill recipes: "
    .. changed_fill
)

log(
    "[BiggerBarrelsCustom] Changed empty recipes: "
    .. changed_empty
)
