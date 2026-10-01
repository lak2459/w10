CREATE TABLE gunpla (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 100),
  model_code TEXT NOT NULL CHECK(length(trim(model_code)) BETWEEN 1 AND 40),
  grade TEXT NOT NULL CHECK(grade IN ('HG','RG','MG','PG','SD')),
  status TEXT NOT NULL CHECK(status IN ('ยังไม่ประกอบ','กำลังประกอบ','ประกอบแล้ว')),
  price_satang INTEGER NOT NULL CHECK(price_satang BETWEEN 0 AND 999999999),
  notes TEXT NOT NULL DEFAULT '' CHECK(length(notes) <= 500)
);
