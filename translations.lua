local csv = require("csv")

local translations = {}

do
  local languages = {}
  local f = csv.open("translations.csv")
  if f then
    local line_n = 1
    for fields in f:lines() do
      if line_n == 1 then
        -- Find languages
        for i, v in ipairs(fields) do
          if i > 1 then
            table.insert(languages, v)
            translations[v] = {}
          end
        end
      else
        -- Find translations
        local key
        for i, v in ipairs(fields) do
          if i == 1 then
            key = v
          else
            local language = languages[i-1]
            translations[language][key] = v
          end
        end
      end
      line_n = line_n + 1
    end
  end
end

local locale = "en"

function setLocale(new_locale)
  locale = new_locale
end

function tr(id)
  local lang = translations[locale]

  if not lang then
    return id
  end

  local translation = lang[id]
  if not translation then
    return id
  end

  return translation
end
