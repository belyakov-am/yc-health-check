package db

var schema = `
CREATE TABLE IF NOT EXISTS status (
	ip TEXT PRIMARY KEY,
	ts TIMESTAMPTZ
);
`

var upsertStatus = `
INSERT INTO status (ip, ts)
VALUES ($1, $2)
ON CONFLICT (ip)
DO UPDATE SET ts = $2; 
`

var selectStatuses = `
SELECT * FROM status;
`
