function Table (elem)
    if elem.classes:includes('no-split') then
      elem.classes:remove('longtable')
      elem.classes:insert('tabular')
    end
    return elem
  end