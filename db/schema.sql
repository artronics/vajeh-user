CREATE TABLE user
(
    email      VARCHAR PRIMARY KEY NOT NULL,
    name       VARCHAR(50),
    created_on TIMESTAMP           NOT NULL,
);
