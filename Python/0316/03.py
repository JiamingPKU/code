import sqlite3

conn = sqlite3.connect("datefile")
cursor = conn.cursor()

cursor.execute("create table test(name text, count integar)")
cursor.execute("insert into test(name, count) values ('Bob',1)")
cursor.execute("insert into test(name, count) values (:username, :usercount)",
               {"username": "Joe",
                "usercount": 10})
result = cursor.execute("select * from test")
print(result.fetchall())

cursor.execute("update test set count=? where name=?", (20, "Jill"))
result = cursor.execute("select * from test")
print(result.fetchall())

conn.commit()
conn.close()
