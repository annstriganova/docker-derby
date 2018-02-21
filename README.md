# Docker Derby

Dockerfile to run Derby in network mode.

## How to use

Build the [image](Dockerfile).

```
docker build -t derby .
```

The following command starts container with the latest version of the [Derby Network Server](http://db.apache.org/derby/papers/DerbyTut/ns_intro.html) listening on port `<dbport>` and creates database `<dbname>` inside.

```bash
docker run --name=derby \
      --env dbname=<dbname> \
      --env dbuser=<dbuser> \
      --env dbpass=<dbpass> \
      --env dbport=<dbport> \
      --expose=<dbport> -P derby
```

Example:

```bash
docker run --name=derby \
      --env dbname=DbTest \
      --env dbuser=axibase \
      --env dbpass=axibase \
      --env dbport=8443 \
      --expose=8443 -P derby
```

Connect to `<dbname>` from client:

* using `ij`:

```bash
anna@axibase:/# ~/test/db-derby-10.14.1.0-bin/bin/ij
ij version 10.14
ij> CONNECT 'jdbc:derby://localhost:32867/DbTest;user=axibase;password=axibase';
ij> CREATE TABLE FIRSTTABLE
     (ID INT PRIMARY KEY,
     NAME VARCHAR(12));
0 rows inserted/updated/deleted
ij> INSERT INTO FIRSTTABLE VALUES 
    (10,'TEN'),(20,'TWENTY'),(30,'THIRTY');

3 rows inserted/updated/deleted
ij> SELECT * FROM FIRSTTABLE;

     ID         |NAME
    ------------------------
    10         |TEN
    20         |TWENTY
    30         |THIRTY

3 rows selected
```
* using [JDBC API](http://db.apache.org/derby/docs/10.7/devguide/cdevdvlp17453.html):

```java
Connection conn = DriverManager.getConnection("jdbc:derby://localhost:32867/DbTest;user=axibase;password=axibase");
```

> `32867` is port retrieved with the `docker port derby`command.
