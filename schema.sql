DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS usergroups;
DROP TABLE IF EXISTS reminders;
DROP TABLE IF EXISTS seen;

CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  nick TEXT NOT NULL
);

CREATE TABLE groups(
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE usergroups(
  user_id INTEGER,
  group_id INTEGER,
  FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY(group_id) REFERENCES groups(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX usersindex ON users(nick);
CREATE UNIQUE INDEX groupsindex ON groups(name);
CREATE UNIQUE INDEX usergroupsindex on usergroups(user_id, group_id);


CREATE TABLE reminders(
  id INTEGER PRIMARY KEY,
  nick TEXT NOT NULL,
  channel TEXT NOT NULL,
  reminder TEXT NOT NULL,
  reminderdate DATETIME NOT NULL
);

CREATE INDEX remindersindex on reminders(nick);

CREATE TABLE seen(
  id INTEGER PRIMARY KEY,
  nick TEXT NOT NULL,
  channel TEXT NOT NULL,
  seendate DATETIME NOT NULL,
  lasttext TEXT NOT NULL
);

CREATE UNIQUE INDEX seenindex on seen(nick);
