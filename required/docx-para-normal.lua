-- Remap all body paragraphs to Normal (Normalny) style in DOCX output.
-- Pandoc hard-codes "First Paragraph" and "Body Text" style IDs regardless
-- of the reference doc; wrapping each Para in a custom-style Div overrides that.
if FORMAT ~= "docx" then return {} end

function Para(elem)
  return pandoc.Div({ elem }, pandoc.Attr("", {}, { ["custom-style"] = "Normal" }))
end
