8.До наявної no-sql DB необхідно розробити структуру бази даних
з використанням SQL (PostgreSQL) для чатів, використовуючи
наявну БД як еталон. Необхідно мінімізувати наслідки після
міграції сервера з no-sql на sql (наприклад, імена стовпців мають
бути однаковими за можливості). Необхідні зміни в реляційній БД
потрібно здійснити за допомогою SQL (CREATE TABLE або ALTER
TABLE, якщо знадобиться). Результати роботи необхідно залити
на GitHub у вигляді SQL файлів.6Г
Надати схеми ERD у вигляді скріншота з усіма можливими
відносинами (не забудьте привязати таблицю юзерів).

CREATE TABLE "Conversations" (
  id SERIAL PRIMARY KEY,
  participant1 INTEGER NOT NULL,
  participant2 INTEGER NOT NULL,
  isBlock1 BOOLEAN NOT NULL,
  isBlock2 BOOLEAN NOT NULL,
  isFavorite1 BOOLEAN NOT NULL,
  isFavorite2 BOOLEAN NOT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY (participant1) REFERENCES "Users"(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (participant2) REFERENCES "Users"(id) ON UPDATE CASCADE ON DELETE RESTRICT
);


CREATE TABLE "Catalogs" (
  id SERIAL PRIMARY KEY,
  userId INTEGER NOT NULL,
  catalogName VARCHAR(255) NOT NULL
  FOREIGN KEY (userId) REFERENCES "Users"(id) ON UPDATE CASCADE ON DELETE RESTRICT,
);

CREATE TABLE Chats (
  id SERIAL PRIMARY KEY,
  catalogId INTEGER NOT NULL,
  conversationId INTEGER NOT NULL
  FOREIGN KEY (catalogId) REFERENCES "Catalogs"(id) ON UPDATE CASCADE ON DELETE RESTRICT
  FOREIGN KEY (conversationId) REFERENCES "Conversations"(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE "Messages" (
  id SERIAL PRIMARY KEY,
  sender INTEGER NOT NULL,
  conversationId INTEGER NOT NULL,
  body TEXT NOT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY (sender) REFERENCES "Users"(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (conversationId) REFERENCES "Conversations"(id) ON UPDATE CASCADE ON DELETE RESTRICT
);



INSERT INTO "Users" ("firstName", "lastName", "displayName", password, email, avatar, role, balance, rating)
VALUES
  ('Aspect', 'Lynch', 'Batman', 'myHash', 'example1@example.com', 'anon.png', 'customer', 0, 4.5),
  ('Kraken', 'Big Papa', 'Robin', 'myHash', 'example2@example.com', 'anon.png', 'customer', 0,  4.2),
  ('Colby', 'Moore', 'Batwoman', 'myHash', 'example3@example.com', 'anon.png', 'creator', 0, 4.6),
  ('Lyndon', 'Stark', 'Superman', 'myHash', 'example4@example.com', 'anon.png', 'creator', 0,  4.3),
  ('Xander', 'Atkins', 'Joker', 'myHash', 'example5@example.com', 'anon.png', 'creator', 0,  0),
  ('Bender', 'Mad Dog', 'Lex Luthor', 'myHash', 'example6@example.com', 'anon.png', 'creator', 0,  4.8);


9.Вивести кількість юзерів за ролями {admin: 40, customer: 22, ...}
SELECT role, COUNT(*) AS count
FROM "Users"
GROUP BY role;

10. Усім юзерам з роллю customer, які здійснювали замовлення в новорічні свята в період з 25.12 по 14.01, необхідно зарахувати по 10% кешбеку з усіх замовлень у цей період.
UPDATE "Users" AS u
SET balance = u.balance + (
  SELECT COALESCE(SUM(c.prize) *0.1, 0)
  FROM "Contests" AS c
  WHERE c."userId" = u.id
    AND "createdAt" >= '2022-12-25'::timestamp
    AND "createdAt" < '2023-01-15'::timestamp
)
WHERE u.role = 'customer';

11.Для ролі сreative необхідно виплатити 3-м юзерам з найвищим рейтингом по 10$ на їхні рахунки.
UPDATE "Users" AS u
SET balance = u.balance + 10
WHERE u.role = 'creator'
  AND u.id IN (
    SELECT id
    FROM "Users"
    WHERE role = 'creator'
    ORDER BY rating DESC
    LIMIT 3
  );
