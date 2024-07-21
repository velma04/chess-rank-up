DROP TABLE IF EXISTS Member CASCADE;
DROP TABLE IF EXISTS Section CASCADE;
DROP TABLE IF EXISTS Semester CASCADE;
DROP TABLE IF EXISTS EventType CASCADE;
DROP TABLE IF EXISTS Event CASCADE;
DROP TABLE IF EXISTS Participation CASCADE;
DROP TABLE IF EXISTS Rank CASCADE;
DROP TABLE IF EXISTS Attribute CASCADE;
DROP TABLE IF EXISTS SectionSemester CASCADE;
DROP TABLE IF EXISTS News CASCADE;
DROP TABLE IF EXISTS SectionMember CASCADE;
DROP TABLE IF EXISTS MemberInfo CASCADE;

CREATE TABLE Member
(
  idMember BIGSERIAL PRIMARY KEY,
  firstName VARCHAR(30) NOT NULL,
  lastName VARCHAR(30) NOT NULL,
  -- jmbag CHAR(10) NOT NULL,
  jmbag VARCHAR(10) NOT NULL CHECK (LENGTH(jmbag) = 10),
  email VARCHAR(50),

  -- 2 bytes for '{' and '}', 10 bytes for name of encoder
  -- 128 bytes for actual hash (the biggest length is for 'argon2')
  -- 32 bytes for salt and 32 bytes for pepper
  -- bigger size is for future use
  passwordHash VARCHAR(255), 
  
  salt VARCHAR(32),

  UNIQUE (jmbag),
  UNIQUE (email)
);

CREATE TABLE Section
(
  idSection BIGSERIAL PRIMARY KEY,
  nameSection VARCHAR(30) NOT NULL,
  descriptionSection VARCHAR(80) NOT NULL,
  logo VARCHAR(80)
);

-- TODO: in backend add constraint so no new semester can intefer with the interval: [dateFrom, dateTo]
-- of any other semester
CREATE TABLE Semester
(
  idSemester BIGSERIAL PRIMARY KEY,
  nameSemester VARCHAR(30) NOT NULL,
  dateFromSemester DATE NOT NULL,
  dateToSemester DATE,
  CONSTRAINT checkDates CHECK (dateToSemester IS NULL OR dateToSemester >= dateFromSemester)
);

CREATE TABLE EventType 
(
  idEventType BIGSERIAL PRIMARY KEY,
  nameEventType VARCHAR(30) NOT NULL,
  defaultPoints INT NOT NULL DEFAULT 0
);

CREATE TABLE Event
(
  idEvent BIGSERIAL PRIMARY KEY,
  nameEvent VARCHAR(30) NOT NULL,
  dateFromEvent DATE NOT NULL,
  dateToEvent DATE,
  descriptionEvent VARCHAR(80) NOT NULL,
  idSection INT NOT NULL,
  idEventType INT NOT NULL,
  FOREIGN KEY (idSection) REFERENCES Section(idSection),
  FOREIGN KEY (idEventType) REFERENCES EventType(idEventType)
);

CREATE TABLE Participation
(
  idParticipation BIGSERIAL PRIMARY KEY,
  addPoints INT NOT NULL DEFAULT 0,
  idMember INT NOT NULL,
  idEvent INT NOT NULL,
  FOREIGN KEY (idMember) REFERENCES Member(idMember),
  FOREIGN KEY (idEvent) REFERENCES Event(idEvent),
  UNIQUE(idMember, idEvent)
);

CREATE TABLE Rank
(
  idRank BIGSERIAL PRIMARY KEY,
  nameRank VARCHAR(30) NOT NULL,
  image VARCHAR(80),
  pointsModifier INT NOT NULL DEFAULT 0,
  pointsRequired INT,  -- NULL if it is impossible to get that rank with the points alone  
  idSection INT NOT NULL,
  FOREIGN KEY (idSection) REFERENCES Section(idSection)
);


CREATE TABLE Attribute
(
  idAttribute BIGSERIAL PRIMARY KEY,
  nameAttribute VARCHAR(30) NOT NULL,
  dataType VARCHAR(20) NOT NULL
);

CREATE TABLE SectionSemester
(
  idSectionSemester BIGSERIAL PRIMARY KEY,
  threshold INT NOT NULL,
  points INT NOT NULL DEFAULT 0,
  idSemester BIGINT NOT NULL,
  idSection BIGINT NOT NULL,
  idMember BIGINT NOT NULL,
  FOREIGN KEY (idSemester) REFERENCES Semester(idSemester),
  FOREIGN KEY (idSection) REFERENCES Section(idSection),
  FOREIGN KEY (idMember) REFERENCES Member(idMember),
  UNIQUE (idMember, idSemester, idSection)
);

CREATE TABLE News
(
  idNews BIGSERIAL PRIMARY KEY,
  title VARCHAR(80) NOT NULL,
  timestampCreated DATE NOT NULL,
  timestampEdited DATE,
  content VARCHAR(80) NOT NULL,
  images VARCHAR(80),
  idSection INT NOT NULL,
  idAuthor INT NOT NULL,
  FOREIGN KEY (idSection) REFERENCES Section(idSection),
  FOREIGN KEY (idAuthor) REFERENCES Member(idMember)
);

CREATE TABLE SectionMember
(
  idSectionMember BIGSERIAL PRIMARY KEY,
  isActive BOOLEAN NOT NULL,
  pointsAll INT NOT NULL DEFAULT 0,
  idMember INT NOT NULL,
  idSection INT NOT NULL,
  idRank INT NOT NULL,
  FOREIGN KEY (idMember) REFERENCES Member(idMember),
  FOREIGN KEY (idSection) REFERENCES Section(idSection),
  FOREIGN KEY (idRank) REFERENCES Rank(idRank),
  UNIQUE (idMember, idSection)
);

CREATE TABLE MemberInfo
(
  idInfo BIGSERIAL PRIMARY KEY,
  stringValue VARCHAR(40), -- can be added later
  showOnProfile BOOLEAN NOT NULL DEFAULT FALSE,
  idSection INT NOT NULL,
  idAttribute INT NOT NULL,
  idMember INT NOT NULL,
  FOREIGN KEY (idSection) REFERENCES Section(idSection),
  FOREIGN KEY (idAttribute) REFERENCES Attribute(idAttribute),
  FOREIGN KEY (idMember) REFERENCES Member(idMember),
  UNIQUE (idSection, idMember, idAttribute)
);
